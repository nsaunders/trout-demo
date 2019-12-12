module Client where

import Prelude
import API (api)
import Credentials (Credentials, mkCredentials)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, attempt)
import Effect.Exception (message)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Core as HC
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import Task (Task, TaskDetails)
import Type.Trout.Client (asClients)

type State =
  { username :: String
  , password :: String
  , newTaskDescription :: String
  , tasks :: Array Task
  , busy :: Boolean
  , error :: Maybe String
  }

data Action
  = GetTasks
  | SetUsername String
  | SetPassword String
  | SetNewTaskDescription String
  | CreateTask

component :: forall q i o. H.Component HH.HTML q i o Aff
component = H.mkComponent
  { initialState
  , render
  , eval: H.mkEval H.defaultEval { handleAction = handleAction, initialize = Just GetTasks }
  }

initialState :: forall i. i -> State
initialState = const
  { username: "admin"
  , password: "admin"
  , newTaskDescription: ""
  , tasks: []
  , busy: false
  , error: Nothing
  }

style :: forall i r. String -> HP.IProp (style ∷ String | r) i
style = HP.attr (HC.AttrName "style")

render :: State -> H.ComponentHTML Action () Aff
render { username, password, newTaskDescription, tasks, busy, error } =
  let
    ready = not busy && username /= "" && password /= "" && newTaskDescription /= ""
  in
    HH.div_
      [ HH.div
          [ style """
              background: #ccc;
              color: #666;
              display: flex;
              flex-flow: row nowrap;
              align-items: center;
              justify-content: center;
              font-family: sans-serif;
              font-size: 14px;
              height: 32px;
            """
          ]
          [ HH.div
              [ style """
                  font-weight: bold;
                  font-family: serif;
                """
              ]
              [ HH.text "Credentials" ]
          , HH.label
              [ style "display: inline-flex; align-items: center; margin-left: 16px;"
              ]
              [ HH.span
                  [ style """
                      font-size: 10px;
                      text-transform: uppercase;
                    """
                  ]
                  [ HH.text "Username" ]
              , HH.input
                  [ HP.value username
                  , HP.placeholder "Username"
                  , HE.onValueInput (Just <<< SetUsername)
                  , HP.disabled busy
                  , style """
                      width: 120px;
                      height: 24px;
                      background: #fff;
                      color: #333;
                      border: 0;
                      border-radius: 4px;
                      font-family: inherit;
                      font-size: inherit;
                      padding: 4px;
                      margin-left: 8px;
                    """
                  ]
              ]
          , HH.label
              [ style "margin-left: 16px; display: inline-flex; align-items: center;"
              ]
              [ HH.span
                  [ style """
                      font-size: 10px;
                      text-transform: uppercase;
                    """
                  ]
                  [ HH.text "Password" ]
              , HH.input
                  [ HP.value password
                  , HP.placeholder "Password"
                  , HE.onValueInput (Just <<< SetPassword)
                  , HP.disabled busy
                  , style """
                      width: 120px;
                      height: 24px;
                      background: #fff;
                      color: #333;
                      border: 0;
                      border-radius: 4px;
                      font-family: inherit;
                      font-size: inherit;
                      padding: 4px;
                      margin-left: 8px;
                    """
                  ]
              ]
          ]
      , HH.div
          [ style "background: #fff; color: #333; font-family: sans-serif; font-size: 16px;"
          ]
          [ HH.div
              [ style "text-align: center; margin: 32px 0;"
              ]
              [ HH.h1 [ style "margin: 0; font-size: 64px; font-family: serif;" ] [ HH.text "Tasks" ]
              ]
          , HH.table
              [ style "margin: 0 auto; border-spacing: 0;"
              ]
              [ HH.thead_
                  [ HH.tr_
                      [ HH.th
                          [ style """
                              border-bottom: 1px solid #333;
                              font-size: 12px;
                              font-weight: bold;
                              text-transform: uppercase;
                              text-align: left;
                              width: 80px;
                              padding: 8px;
                            """
                          ]
                          [ HH.text "ID" ]
                      , HH.th
                          [ style """
                              border-bottom: 1px solid #333;
                              font-size: 12px;
                              font-weight: bold;
                              text-transform: uppercase;
                              text-align: left;
                              width: 256px;
                              padding: 8px;
                            """
                          ]
                          [ HH.text "Description" ]
                      , HH.th
                          [ style """
                              border-bottom: 1px solid #333;
                              font-size: 12px;
                              font-weight: bold;
                              text-transform: uppercase;
                              text-align: left;
                              width: 144px;
                              padding: 8px;
                            """
                          ]
                          [ HH.text "Owner" ]
                      ]
                  ]
              , HH.tbody_ $ map
                  (\{ id, description, owner } ->
                    HH.tr_
                      [ HH.td [ style "padding: 8px" ] [ HH.text $ show id ]
                      , HH.td [ style "padding: 8px" ] [ HH.text description ]
                      , HH.td [ style "padding: 8px" ] [ HH.text owner ]
                      ]
                  )
                  tasks
              ]
          , HH.div
              [ style "margin: 32px 0; text-align: center;" ]
              [ HH.h2 [ style "font-size: 32px; font-family: serif;" ] [ HH.text "New Task" ]
              , HH.label
                  [ style "display: inline-flex; flex-flow: column nowrap;"
                  ]
                  [ HH.span
                      [ style """
                          font-size: 10px;
                          text-transform: uppercase;
                          text-align: left;
                        """
                      ]
                      [ HH.text "Description" ]
                  , HH.input
                      [ HP.value newTaskDescription
                      , HP.placeholder "e.g. Pick up the dry cleaning."
                      , HP.disabled busy
                      , HE.onValueInput (Just <<< SetNewTaskDescription)
                      , style """
                          width: 240px;
                          height: 24px;
                          background: #fff;
                          color: #333;
                          border: 1px solid #ccc;
                          border-radius: 4px;
                          font-family: inherit;
                          font-size: inherit;
                          padding: 4px;
                          margin-top: 4px;
                        """
                      ]
                  ]
              , HH.div
                [ style "margin-top: 16px;" ]
                [ HH.button
                    [ style $ """
                        font-family: inherit;
                        font-size: inherit;
                        padding: 8px;
                        border-radius: 4px;
                        border: 0;
                        color: #fff;
                      """ <> if not ready then "background: #ccc;" else "background: #666;"
                    , HP.disabled $ not ready
                    , HE.onClick \_ -> Just CreateTask
                    ]
                    [ HH.text "Create Task" ]
                ]
              , HH.div
                [ style "margin-top: 16px; color: red;" ] $
                case error of
                  Nothing -> []
                  Just e -> [ HH.text e ]
              ]
          ]
    ]

clients
  :: { tasks ::
       { list :: { "GET" :: Aff (Array Task) }
       , item :: Int -> { "GET" :: Aff Task }
       , newItem :: Credentials -> TaskDetails -> { "POST" :: Aff Task }
       }
     }
clients = asClients api

handleAction :: forall o. Action -> H.HalogenM State Action () o Aff Unit
handleAction = case _ of
  GetTasks -> do
    H.modify_ (_ { busy = true })
    getRequest <- H.liftAff $ attempt clients.tasks.list."GET"
    case getRequest of
      Left error ->
        H.modify_ (_ { busy = false, error = Just $ "Could not retrieve tasks: " <> message error })
      Right tasks ->
        H.modify_ (_ { busy = false, tasks = tasks })
  SetUsername username ->
    H.modify_ (_ { username = username })
  SetPassword password ->
    H.modify_ (_ { password = password })
  SetNewTaskDescription description ->
    H.modify_ (_ { newTaskDescription = description })
  CreateTask -> do
    credentials <- mkCredentials <$> H.gets _.username <*> H.gets _.password
    description <- H.gets _.newTaskDescription
    H.modify_ (_ { busy = true, error = Nothing })
    createRequest <- H.liftAff $ attempt ((asClients api).tasks.newItem credentials { description })."POST"
    case createRequest of
      Left error ->
        H.modify_ (_ { busy = false, error = Just $ "Could not create task: " <> message error })
      Right _ -> do
        H.modify_ (_ { newTaskDescription = "" })
        refreshRequest <- H.liftAff $ attempt clients.tasks.list."GET"
        case refreshRequest of
          Left error ->
            H.modify_ (_ { busy = false, error = Just $ "Could not retrieve tasks: " <> message error })
          Right tasks ->
            H.modify_ (_ { busy = false, tasks = tasks })
    pure unit

main :: Effect Unit
main = HA.runHalogenAff $ HA.awaitBody >>= runUI component unit

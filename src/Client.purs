module Client where

import Prelude
import API (api)
import Credentials (Credentials(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import Task (Task, TaskDetails)
import Type.Trout.Client (asClients)

type State =
  { username :: Maybe String
  , password :: Maybe String
  , newTaskDescription :: Maybe String
  , tasks :: Array Task
  , busy :: Boolean
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
  { username: Nothing
  , password: Nothing
  , newTaskDescription: Nothing
  , tasks: []
  , busy: false
  }

render :: State -> H.ComponentHTML Action () Aff
render { username, password, newTaskDescription, tasks, busy } = HH.div_
  [ HH.ul_ $ map
      (\{ id, description, owner } ->
        HH.li_ [ HH.text $ description <> " (ID: " <> show id <> ", owner: " <> owner <> ")" ]
      )
      tasks
  , HH.div_
      [ HH.input
          [ HP.value $ fromMaybe "" username
          , HP.placeholder "Username"
          , HP.disabled busy
          , HE.onValueInput (Just <<< SetUsername)
          ]
      , HH.input
          [ HP.value $ fromMaybe "" password
          , HP.placeholder "Password"
          , HP.disabled busy
          , HE.onValueInput (Just <<< SetPassword)
          ]
      , HH.input
          [ HP.value $ fromMaybe "" newTaskDescription
          , HP.placeholder "Description"
          , HP.disabled busy
          , HE.onValueInput (Just <<< SetNewTaskDescription)
          ]
      , HH.button [ HP.disabled busy, HE.onClick \_ -> Just CreateTask ] [ HH.text "Create Task" ]
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
    tasks <- H.liftAff $ clients.tasks.list."GET"
    H.modify_ (_ { busy = false, tasks = tasks })
  SetUsername u ->
    H.modify_ (_ { username = Just u })
  SetPassword p ->
    H.modify_ (_ { password = Just p })
  SetNewTaskDescription d ->
    H.modify_ (_ { newTaskDescription = Just d })
  CreateTask -> do
    usernameMaybe <- H.gets _.username
    passwordMaybe <- H.gets _.password
    let credentialsMaybe = (\u p -> Credentials { username: u, password: p }) <$> usernameMaybe <*> passwordMaybe
    descriptionMaybe <- H.gets _.newTaskDescription
    case (Tuple <$> credentialsMaybe <*> descriptionMaybe) of
      Nothing ->
        pure unit
      Just (Tuple credentials description) -> do
        H.modify_ (_ { busy = true, newTaskDescription = Nothing })
        _ <- H.liftAff ((asClients api).tasks.newItem credentials { description })."POST"
        tasks <- H.liftAff $ clients.tasks.list."GET"
        H.modify_ (_ { busy = false, tasks = tasks })
        pure unit

main :: Effect Unit
main = HA.runHalogenAff $ HA.awaitBody >>= runUI component unit

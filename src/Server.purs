module Server where

import Prelude
import API (api)
import Control.Monad.Except.Trans (ExceptT, throwError)
import Credentials (Credentials, username)
import Data.Array (snoc)
import Data.Either (Either(..))
import Data.Foldable (find)
import Data.Maybe (Maybe(..))
import Data.String.CodePoints (take) as String
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (message)
import Effect.Ref (modify, modify_, new, read) as Ref
import Node.Encoding (Encoding(UTF8))
import Node.FS.Async (readFile)
import Node.HTTP (Request, Response, createServer, listen, requestURL, responseAsStream, setStatusCode)
import Node.Path (concat) as Path
import Node.Stream (end, write, writeString) as Stream
import Nodetrout (HTTPError, error404, serve')
import Task (Task, TaskDetails)

mkHandlers
  :: Effect
       { tasks ::
         { list :: { "GET" :: ExceptT HTTPError Aff (Array Task) }
         , item :: Int -> { "GET" :: ExceptT HTTPError Aff Task }
         , newItem :: Credentials -> TaskDetails -> { "POST" :: ExceptT HTTPError Aff Task }
         }
       }
mkHandlers = do
  taskRef <- Ref.new []
  idRef <- Ref.new 0
  pure
    { tasks:
      { list: { "GET": liftEffect $ Ref.read taskRef }
      , item: \id ->
          { "GET": do
            tasks <- liftEffect $ Ref.read taskRef
            case find (\t -> t.id == id) tasks of
              Nothing ->
                throwError error404 { details = Just ("No task matches the specified ID " <> show id <> ".") }
              Just task ->
                pure task
          }
      , newItem: \credentials { description } ->
          { "POST": do
            id <- liftEffect $ Ref.modify (_ + 1) idRef
            let task = { id, description, owner: username credentials }
            liftEffect $ Ref.modify_ (_ `snoc` task) taskRef
            pure task
          }
      }
    }

serveStatic :: Request -> Response -> Effect Unit
serveStatic req res =
  let
    rs = responseAsStream res
    url = case requestURL req of
            "/" -> "/index.html"
            somethingElse -> somethingElse
  in
    readFile (Path.concat ["static", url]) $
      case _ of
        Left error -> do
          setStatusCode res 500
          _ <- Stream.writeString rs UTF8 (message error) $ pure unit
          Stream.end rs $ pure unit
        Right b -> do
          setStatusCode res 200
          _ <- Stream.write rs b $ pure unit
          Stream.end rs $ pure unit

main :: Effect Unit
main = do
  handlers <- mkHandlers
  server <- createServer \req ->
              if String.take 4 (requestURL req) == "/api"
                then serve' api handlers (const $ pure unit) req
                else serveStatic req
  listen server { hostname: "0.0.0.0", port: 3000, backlog: Nothing } $ pure unit

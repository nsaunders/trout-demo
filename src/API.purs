module API where

import Credentials (Credentials)
import Task (Task, TaskDetails)
import Type.Proxy (Proxy(..))
import Type.Trout (type (:=), type (:<|>), type (:/), type (:>), Capture, Header, ReqBody)
import Type.Trout.ContentType.JSON (JSON)
import Type.Trout.Method (Get, Post)

type API =
  "tasks" := "api" :/ "tasks" :/ (
         "list" := Get (Array Task) JSON
    :<|> "item" := Capture "id" Int :> Get Task JSON 
    :<|> "newItem" := Header "Authorization" Credentials :> ReqBody TaskDetails JSON :> Post Task JSON
  )

api :: Proxy API
api = Proxy

module Task where

type TaskDetailsRep = ( description :: String )

type TaskDetails = { | TaskDetailsRep }

type Task = { id :: Int, owner :: String | TaskDetailsRep }

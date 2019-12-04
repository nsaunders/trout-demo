module Credentials where

import Prelude
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.String.Base64 (decode, encode)
import Data.String.Common (split, toLower) as String
import Data.String.CodePoints (drop, take) as String
import Data.String.Pattern (Pattern(..))
import Effect.Exception (message)
import Type.Trout.Header (class FromHeader, class ToHeader)

newtype Credentials = Credentials { username :: String, password :: String }

username :: Credentials -> String
username (Credentials c) = c.username

instance fromHeaderCredentials :: FromHeader Credentials where
  fromHeader headerValue
    | String.toLower (String.take 6 headerValue) /= "basic " = Left "Only Basic authorization is supported."
    | otherwise = do
        payload <- lmap (\e -> "Failed to decode header: " <> message e) $ decode (String.drop 6 headerValue)
        case String.split (Pattern ":") payload of
          [ user, pass ] ->
            pure $ Credentials { username: user, password: pass }
          _ ->
            Left "The Authorization header is invalid."

instance toHeaderCredentials :: ToHeader Credentials where
  toHeader (Credentials c) = "Basic " <> encode (c.username <> ":" <> c.password)

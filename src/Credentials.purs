module Credentials where

import Prelude
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.String.Base64 (decode, encode)
import Data.String.Common (split, toLower) as String
import Data.String.CodePoints (drop, take) as String
import Data.String.Pattern (Pattern(..))
import Data.Tuple (Tuple(..), fst, snd)
import Effect.Exception (message)
import Type.Trout.Header (class FromHeader, class ToHeader)

newtype Credentials = Credentials (Tuple String String)

mkCredentials :: String -> String -> Credentials
mkCredentials u p = Credentials $ Tuple u p

username :: Credentials -> String
username (Credentials c) = fst c

password :: Credentials -> String
password (Credentials c) = snd c

instance fromHeaderCredentials :: FromHeader Credentials where
  fromHeader headerValue
    | String.toLower (String.take 6 headerValue) /= "basic " = Left "Only Basic authorization is supported."
    | otherwise = do
        payload <- lmap (\e -> "Failed to decode header: " <> message e) $ decode (String.drop 6 headerValue)
        case String.split (Pattern ":") payload of
          [ user, pass ] ->
            pure $ Credentials (Tuple user pass)
          _ ->
            Left "The Authorization header is invalid."

instance toHeaderCredentials :: ToHeader Credentials where
  toHeader credentials = "Basic " <> encode (username credentials <> ":" <> password credentials)

module Polysemy.Http.Data.HttpError where

data HttpError =
  AuthFailed Text
  |
  ServerError Int Text
  |
  Parse LByteString Text
  |
  ChunkFailed Text
  |
  Internal Text
  |
  FileSystem Text
  deriving (Eq, Show)
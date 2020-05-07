module Polysemy.Http.Strict where

import Polysemy (interpretH, pureT)
import Polysemy.Internal.Tactics hiding (liftT)

import Polysemy.Http.Data.Header (Header(Header))
import Polysemy.Http.Data.Http (Http)
import qualified Polysemy.Http.Data.Http as Http
import Polysemy.Http.Data.HttpError (HttpError)
import Polysemy.Http.Data.Response (Response(Response))

takeResponse ::
  Member (State [Response LByteString]) r =>
  [Response LByteString] ->
  Sem r (Either a (Response LByteString))
takeResponse (response : rest) =
  Right response <$ put rest
takeResponse [] =
  pure (Right (Response 502 "test responses exhausted" []))

takeChunk ::
  Member (State [ByteString]) r =>
  [ByteString] ->
  Sem r ByteString
takeChunk (chunk : rest) =
  chunk <$ put rest
takeChunk [] =
  pure ""

interpretHttpLocalWithState ::
  Members [Embed IO, State [ByteString], State [Response LByteString], Error HttpError] r =>
  InterpreterFor (Http Int) r
interpretHttpLocalWithState =
  interpretH $ \case
    Http.Request _ ->
      liftT . takeResponse =<< raise get
    Http.Stream _ handler -> do
      handle <- bindT handler
      resp <- pureT (Response 200 1 [Header "content-disposition" [qt|filename="file.txt"|]])
      raise (interpretHttpLocalWithState (handle resp))
    Http.ConsumeChunk _ ->
      liftT . fmap Right . takeChunk =<< raise get

interpretHttpStrict ::
  Members [Embed IO, Error HttpError] r =>
  [Response LByteString] ->
  [ByteString] ->
  InterpreterFor (Http Int) r
interpretHttpStrict responses chunks =
  evalState chunks . evalState responses . interpretHttpLocalWithState . raiseUnder . raiseUnder
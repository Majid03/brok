{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Parser.Links
    ( Link
    , ParseError
    , links
    ) where

import ClassyPrelude

import Data.List (nub)

import Parser.Parsec

type Link = Text

type ParseError = Text

type Token = Maybe Link

-- parentheses
parens :: Parser Text -> Parser Text
parens parser = surround '(' ')' parser <|> surround '[' ']' parser

-- urls
urlChar :: Parser Char
urlChar = alphaNum <|> oneOf "-._~:/?#%@!$&*+,;="

urlChars :: Parser Text
urlChars = concat <$> many1 (parens urlChars <|> (pack <$> many1 urlChar))

url :: Parser Token
url = Just <$> (concat4 <$> text "http" <*> chopt 's' <*> text "://" <*> urlChars)

noise :: Parser Token
noise = anyToken >> return Nothing

urls :: Parser [Link]
urls = nub . catMaybes <$> many1 (try1 url <|> noise)

-- run parser
links :: Text -> Either ParseError [Link]
links content =
    case parse urls "" content of
        Right c -> Right c
        Left e  -> Left $ tshow e

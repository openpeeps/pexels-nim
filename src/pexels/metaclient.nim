# This package provides a Nim API client for the
# Pexels.com API: https://www.pexels.com/api/
#
# (c) 2024 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/pexels-nim

import std/[asyncdispatch, httpclient, tables,
  strutils, sequtils, times]

from std/httpcore import HttpMethod

import pkg/jsony

export HttpMethod, asyncdispatch, httpclient,
        tables, sequtils

type
  PexelsEndpoint* = enum
    epSearchPhotos = "search"
    epCuratedPhotos = "curated"
    epGetPhoto = "photos/$1"
    epSearchVideos = "videos/search"
    epPopularVideos = "videos/popular"
    epGetVideo = "videos/videos/$1"
    epFeaturedCollections = "collections/featured"
    epMyCollections = "collections"
    epCollectionMedia = "collections/$1"

  PexelsLocale* = enum
    localeAny
    localeEN = "en-US"
    localePT = "pt-BR"
    localeES = "es-ES"
    localeCA = "ca-ES"
    localeDE = "de-DE"
    localeIT = "it-IT"
    localeFR = "fr-FR"
    localeSV = "sv-SE"
    localeID = "id-ID"
    localePL = "pl-PL"
    localeJA = "ja-JP"
    localeZH_TW = "zh-TW"
    localeZH = "zh-CN"
    localeKO = "ko-KR"
    localeTH = "th-TH"
    localeNL = "nl-NL"
    localeHU = "hu-HU"
    localeVI = "vi-VN"
    localeCS = "cs-CZ"
    localeDA = "da-DK"
    localeFI = "fi-FI"
    localeUK = "uk-UA"
    localeEL = "el-GR"
    localeRO = "ro-RO"
    localeNB = "nb-NO"
    localeSK = "sk-SK"
    localeTR = "tr-TR"
    localeRU = "ru-RU"

  PexelsListingResponse* = object of RootObj
    page*, per_page*, total_results*: uint
    next_page*, prev_page*: string

  Pexels* = ref object
    apiKey*: string
    client*: AsyncHttpClient
    query*: QueryTable

  QueryTable* = OrderedTable[string, string]

const
  basePexelsUri = "https://api.pexels.com/v1/"

proc newPexelsClient*(apiKey: sink string): Pexels =
  ## Creates a new instance of `Pexels`.
  new(result)
  result.apiKey = apiKey
  result.client = newAsyncHttpClient()
  result.client.headers = newHttpHeaders({
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": result.apiKey,
  })

#
# JSONY hooks
#
proc parseHook*(s: string, i: var int, v: var Time) =
  var str: string
  parseHook(s, i, str)
  v = parseTime(str, "yyyy-MM-dd'T'hh:mm:ss'.'ffffffz", local())

proc dumpHook*(s: var string, v: Time) =
  add s, '"'
  add s, v.format("yyyy-MM-dd'T'hh:mm:ss'.'ffffffz", local())
  add s, '"'

proc `$`*(query: QueryTable): string =
  ## Convert `query` QueryTable to string
  if query.len > 0:
    add result, "?"
    add result, join(query.keys.toSeq.mapIt(it & "=" & query[it]), "&")

#
# Http Request Handles
#
proc endpoint*(uri: PexelsEndpoint,
    query: QueryTable, args: seq[string]): string =
  ## Return the url string of an endpoint
  result = basePexelsUri & $uri & $query
  if args.len > 0:
    result = result % args

proc httpGet*(client: Pexels, ep: PexelsEndpoint,
    args: seq[string] = newSeq[string](0)): Future[AsyncResponse] {.async.} =
  ## Makes a `GET` request to some `PexelsEndpoint`
  let uri = endpoint(ep, client.query, args)
  result = await client.client.request(uri, HttpGet)

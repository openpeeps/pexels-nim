# This package provides a Nim API client for the
# Pexels.com API: https://www.pexels.com/api/
#
# (c) 2024 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/pexels-nim
import std/[strutils, colors]
import pkg/jsony

import ./metaclient

type
  PexelsPhotoSizes* = object
    original*, large2x*, large*,
      medium*, small*, portrait*,
      landscape*, tiny*: string

  PexelsPhotoResponse* = object
    id*, width*, height*: uint
    url*, photographer*, photographer_url*,
      avg_color*: string
    src*: PexelsPhotoSizes
    liked*: bool # ? not sure what's this
    alt*: string

  PexelsPhotosResponse* = object of PexelsListingResponse
    photos*: seq[PexelsPhotoResponse]

  PexelsOrientationParameter* = enum
    orientationAny
    orientationLandscape = "landscape",
    orientationPortrait = "portrait",
    orientationSquare = "square"
  
  PexelsSizeParameter* = enum
    sizeAny
    sizeLarge = "large"
    sizeMedium = "medium"
    sizeSmall = "small"

  PexelsColorParameter* = enum
    colorAny
    colorRed = "red"
    colorOrange = "orange"
    colorYellow = "yellow"
    colorGreen = "green"
    colorTurquoise = "turquoise"
    colorBlue = "blue"
    colorViolet = "violet"
    colorPink = "pink"
    colorBrown = "brown"
    colorBlack = "black"
    colorGray = "gray"
    colorWhite = "white"
    colorHex

  PexelsSearchParameters* = ref object
    orientation*: PexelsOrientationParameter
    size*: PexelsSizeParameter
    case color*: PexelsColorParameter
    of colorHex:
      hexColor*: Color
    else: discard
    locale*: PexelsLocale
    perPage*: uint = 15
    page*: uint = 1


proc `$`*(photosResponse: PexelsPhotosResponse): string =
  ## Convert `PexelsPhotosResponse` object to JSON
  photosResponse.toJson()

proc `$`*(photoResponse: PexelsPhotoResponse): string =
  ## Convert `PexelsPhotoResponse` object to JSON
  photoResponse.toJson()

proc insert(q: var QueryTable, p: PexelsSearchParameters) =
  case p.locale
    of localeAny: discard
    else:
      q["locale"] = $(p.locale)
  case p.color
    of colorAny: discard
    else:
      q["color"] = $(p.color)
  case p.size:
    of sizeAny: discard
    else:
      q["size"] = $(p.size)
  case p.orientation:
    of orientationAny: discard
    else:
      q["orientation"] = $(p.orientation)
  q["page"] = $(p.page)
  q["per_page"] = $(p.perPage)

#
# Public procs
#
proc search*(px: Pexels, query: string): Future[PexelsPhotosResponse] {.async.} =
  px.query["query"] = query
  let res: AsyncResponse = await px.httpGet(PexelsEndpoint.epSearchPhotos)
  let body = await res.body
  result = fromJson(body, PexelsPhotosResponse)
  px.client.close()

proc search*(px: Pexels, query: string, perPage: uint): Future[PexelsPhotosResponse] {.async.} =
  px.query["query"] = query
  px.query["per_page"] = $(perPage)
  let res: AsyncResponse = await px.httpGet(PexelsEndpoint.epSearchPhotos, @[])
  let body = await res.body
  result = fromJson(body, PexelsPhotosResponse)
  px.client.close()

proc search*(px: Pexels, query: string, params: PexelsSearchParameters): Future[PexelsPhotosResponse] {.async.} =
  px.query["query"] = query
  insert px.query, params
  let res: AsyncResponse = await px.httpGet(PexelsEndpoint.epSearchPhotos, @[])
  let body = await res.body
  result = fromJson(body, PexelsPhotosResponse)
  px.client.close()

#
# Iterators
#
iterator items*(photosResponse: PexelsPhotosResponse): PexelsPhotoResponse =
  for p in photosResponse.photos:
    yield p

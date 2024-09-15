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
  PexelsVideoQuality* = enum
    videoQualitySD = "sd"
    videoQualityHD = "hd"
    videoQualityHLS = "hls"
    videoQualityUHD = "uhd"

  PexelsVideographer* = object
    id*: uint
    name*, url*: string
  
  PexelsVideoFile* = object
    id*: uint
    quality*: PexelsVideoQuality
    file_type*: string
    width*, height*: uint
    fps: float
    link*: string

  PexelsVideoPicture* = object
    id*: uint
    picture*: string
    nr*: uint

  PexelsVideoResponse* = object
    id*, width*, height*: uint
    url*, image*: string
    duration*: uint
    user*: PexelsVideographer
    video_files*: seq[PexelsVideoFile]
    video_pictures*:  seq[PexelsVideoPicture]

  PexelsVideosResponse* = object of PexelsListingResponse
    videos*: seq[PexelsVideoResponse]

proc `$`*(videosResponse: PexelsVideosResponse): string =
  ## Convert `PexelsVideosResponse` object to JSON
  videosResponse.toJson()

proc `$`*(videoResponse: PexelsVideoPicture): string =
  ## Convert `PexelsVideoPicture` object to JSON
  videoResponse.toJson()

proc videos*(pexels: Pexels, query: string): Future[PexelsVideosResponse] {.async.} =
  ## Search for videos by `query`
  pexels.query["query"] = query
  let res: AsyncResponse = await pexels.httpGet(PexelsEndpoint.epSearchVideos)
  let body = await res.body
  result = fromJson(body, PexelsVideosResponse)
  pexels.client.close()

iterator items*(videosResponse: PexelsVideosResponse): PexelsVideoResponse =
  for v in videosResponse.videos:
    yield v

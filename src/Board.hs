{-# LANGUAGE BangPatterns #-}

module Board where

import Data.Array ( (//), listArray, Array )
import Data.Foldable ( foldl' )


type Point = (Int, Int)
data CellType = Empty | Snake | SnakeHead | Apple deriving (Show, Eq)

data BoardInfo = BoardInfo {height :: Int, width :: Int} deriving (Show, Eq)
type Board = Array Point CellType
type DeltaBoard = [(Point, CellType)]

data RenderMessage = RenderBoard DeltaBoard | GameOver
data RenderState   = RenderState {board :: Board, info :: BoardInfo, gameOver :: Bool}

-- | Creates the empty grip from its info
emptyGrid :: BoardInfo -> Board
emptyGrid (BoardInfo h w) = listArray boardBounds emptyCells
    where boardBounds =  ((1, 1), (h, w))
          emptyCells  = replicate (h*w) Empty

-- | Given BoardInfo, init point of snake and init point of apple, builds a board
buildInitialBoard 
  :: BoardInfo -- ^ Board size
  -> Point     -- ^ initial point of the snake
  -> Point     -- ^ initial Point of the apple
  -> RenderState
buildInitialBoard bInfo initSnake initApple = 
  RenderState b bInfo False 
 where b = emptyGrid bInfo // [(initSnake, SnakeHead), (initApple, Apple)]

updateRenderState :: RenderState -> RenderMessage -> RenderState
updateRenderState (RenderState b binf gOver) message = 
  case message of
    RenderBoard delta -> RenderState (b // delta) binf gOver
    GameOver          -> RenderState b binf True

-- | Provisional Pretty printer
ppCell :: CellType -> String
ppCell Empty     = "·"
ppCell Snake     = "0"
ppCell SnakeHead = "$"
ppCell Apple     = "X"

render :: RenderState -> String
render (RenderState b binf@(BoardInfo _ w) gOver) =
  if gOver
    then fst $ boardToString(emptyGrid binf)
    else fst $ boardToString b
  where 
    boardToString =  foldl' fprint ("", 0)
    fprint (!s, !i) cell = 
      if ((i + 1) `mod` w) == 0 
        then (s <> ppCell cell <> "\n", i + 1 )
        else (s <> ppCell cell , i + 1)
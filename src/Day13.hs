module Day13 (solve) where
import           Data.List (foldl', intercalate)
import           Data.Set (Set)
import qualified Data.Set as Set
import           Text.Megaparsec (sepEndBy1, some, (<|>))
import qualified Text.Megaparsec.Char as P
import qualified Text.Megaparsec.Char.Lexer as L
import           Util (Parser, Point, aocTemplate)
import           Debug.Trace (trace)

data Axis = X | Y
data Fold = Fold Axis Int
data Input = Input (Set Point) [Fold]

parser :: Parser Input
parser = Input <$> points <* P.eol <*> sepEndBy1 fold P.eol where
     points = Set.fromList <$> some point
     point = (,) <$> L.decimal <* P.char ',' <*> L.decimal <* P.eol
     fold = Fold <$> (P.string "fold along " *> axis) <* P.char '=' <*> L.decimal
     axis = X <$ P.char 'x' <|> Y <$ P.char 'y'

foldPaper :: Fold -> Set Point -> Set Point
foldPaper (Fold X i) = Set.map \(x, y) -> (min x (2*i - x), y)
foldPaper (Fold Y i) = Set.map \(x, y) -> (x, min y (2*i - y))

part1 :: Input -> Int
part1 (Input paper folds) = Set.size $ foldPaper (head folds) paper

part2 :: Input -> Int
part2 (Input paper folds) = trace str 0 where
    str = intercalate "\n" 
        [
            [if Set.member (x, y) folded then '#' else ' ' | x <- [0..xMax]]
            | y <- [0..yMax]        
        ]
    folded = foldl' (flip foldPaper) paper folds
    xMax = maximum (Set.map fst folded)
    yMax = maximum (Set.map snd folded)

solve :: String -> IO ()
solve = aocTemplate parser (Just . part1) (Just . part2)
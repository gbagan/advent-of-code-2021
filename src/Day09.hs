module Day09 (solve) where
import           RIO hiding (some)
import           RIO.Char.Partial (digitToInt)
import           RIO.List (find, sort)
import           Data.Map.Lazy ((!))
import qualified Data.Map.Lazy as LMap
import           Text.Megaparsec (sepEndBy1, some)
import qualified Text.Megaparsec.Char as P
import           Util (Parser, Point, aocTemplate, adjacentPoints, freqs, listTo2dMap)

parser :: Parser (Map Point Int)
parser = listTo2dMap <$> line `sepEndBy1` P.eol where
        line = some (digitToInt <$> P.digitChar)

flow :: Map Point Int -> Map Point (Maybe Point)
flow m = LMap.mapWithKey go m where
    go p v = find
                (\p2 -> LMap.findWithDefault 10 p2 m < v)
                (adjacentPoints p)

closure :: Map Point (Maybe Point) -> Map Point Point
closure m = cl where
        cl = LMap.mapWithKey (\p -> \case
                     Nothing -> p
                     Just c -> cl ! c  
                  ) m

part1 :: Map Point Int -> Int
part1 m = sum . map ((+1) . (m!) . fst) . filter (isNothing . snd) . LMap.toList . flow $ m 

part2 :: Map Point Int -> Int
part2 = product . take 3 . reverse . sort . LMap.elems . freqs . LMap.elems . closure . flow . LMap.filter (<9)

solve :: (HasLogFunc env) => Text -> RIO env ()
solve = aocTemplate parser pure (pure . part1) (pure . part2)

{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}

module Urbit.Ob.Co (
    Patp
  , render

  , patp
  , fromPatp
  ) where

import qualified Data.ByteString as BS
import qualified Data.Vector as V
import qualified Data.Serialize as C
import qualified Data.Text as T
import Data.Word (Word8, Word16)
import Numeric.Natural (Natural)
import Urbit.Ob.Ob (fein, fynd)

newtype Patp = Patp BS.ByteString
  deriving (Eq, Show)

-- | Convert a Natural to a Patp value.
patp :: Natural -> Patp
patp n
    | met 3 sxz <= 1 = Patp (BS.cons 0 (BS.singleton sxz8))
    | otherwise      = Patp (C.encode sxz)
  where
    sxz  = fein n
    sxz8 = fromIntegral sxz :: Word8

-- | Convert a Patp value to a Natural.
fromPatp :: Patp -> Natural
fromPatp (Patp p) = decoded where
  decoded = case BS.length p of
    2 -> case C.decode p :: Either String Word16 of
      Left e  -> internalErr "fromPatp" e
      Right x -> fynd (fromIntegral x)
    _ -> case C.decode p :: Either String Natural of
      Left e  -> internalErr "fromPatp" e
      Right x -> fynd x

-- | Render a Patp value as Text.
render :: Patp -> T.Text
render (Patp p) = prefixed where
  prefix = V.unsafeIndex prefixes . fromIntegral
  suffix = V.unsafeIndex suffixes . fromIntegral

  prefixed = case T.uncons encoded of
    Just ('-', pp) -> T.cons '~' pp
    Just _         -> T.cons '~' encoded
    _              -> internalErr "render" mempty

  encoded = foldr alg mempty pruned where
    alg (idx, x) acc
      | odd idx   =        suffix x <> acc
      | otherwise = "-" <> prefix x <> acc

  pruned =
    let len = BS.length p
        indexed = zip [len, pred len..] (BS.unpack p)
        padding (idx, val) = idx /= 1 && val == 0
    in  dropWhile padding indexed

prefixes :: V.Vector T.Text
prefixes = V.fromList
  ["doz","mar","bin","wan","sam","lit","sig","hid","fid","lis","sog","dir"
  ,"wac","sab","wis","sib","rig","sol","dop","mod","fog","lid","hop","dar"
  ,"dor","lor","hod","fol","rin","tog","sil","mir","hol","pas","lac","rov"
  ,"liv","dal","sat","lib","tab","han","tic","pid","tor","bol","fos","dot"
  ,"los","dil","for","pil","ram","tir","win","tad","bic","dif","roc","wid"
  ,"bis","das","mid","lop","ril","nar","dap","mol","san","loc","nov","sit"
  ,"nid","tip","sic","rop","wit","nat","pan","min","rit","pod","mot","tam"
  ,"tol","sav","pos","nap","nop","som","fin","fon","ban","mor","wor","sip"
  ,"ron","nor","bot","wic","soc","wat","dol","mag","pic","dav","bid","bal"
  ,"tim","tas","mal","lig","siv","tag","pad","sal","div","dac","tan","sid"
  ,"fab","tar","mon","ran","nis","wol","mis","pal","las","dis","map","rab"
  ,"tob","rol","lat","lon","nod","nav","fig","nom","nib","pag","sop","ral"
  ,"bil","had","doc","rid","moc","pac","rav","rip","fal","tod","til","tin"
  ,"hap","mic","fan","pat","tac","lab","mog","sim","son","pin","lom","ric"
  ,"tap","fir","has","bos","bat","poc","hac","tid","hav","sap","lin","dib"
  ,"hos","dab","bit","bar","rac","par","lod","dos","bor","toc","hil","mac"
  ,"tom","dig","fil","fas","mit","hob","har","mig","hin","rad","mas","hal"
  ,"rag","lag","fad","top","mop","hab","nil","nos","mil","fop","fam","dat"
  ,"nol","din","hat","nac","ris","fot","rib","hoc","nim","lar","fit","wal"
  ,"rap","sar","nal","mos","lan","don","dan","lad","dov","riv","bac","pol"
  ,"lap","tal","pit","nam","bon","ros","ton","fod","pon","sov","noc","sor"
  ,"lav","mat","mip","fip"]

suffixes :: V.Vector T.Text
suffixes = V.fromList
  ["zod","nec","bud","wes","sev","per","sut","let","ful","pen","syt","dur"
  ,"wep","ser","wyl","sun","ryp","syx","dyr","nup","heb","peg","lup","dep"
  ,"dys","put","lug","hec","ryt","tyv","syd","nex","lun","mep","lut","sep"
  ,"pes","del","sul","ped","tem","led","tul","met","wen","byn","hex","feb"
  ,"pyl","dul","het","mev","rut","tyl","wyd","tep","bes","dex","sef","wyc"
  ,"bur","der","nep","pur","rys","reb","den","nut","sub","pet","rul","syn"
  ,"reg","tyd","sup","sem","wyn","rec","meg","net","sec","mul","nym","tev"
  ,"web","sum","mut","nyx","rex","teb","fus","hep","ben","mus","wyx","sym"
  ,"sel","ruc","dec","wex","syr","wet","dyl","myn","mes","det","bet","bel"
  ,"tux","tug","myr","pel","syp","ter","meb","set","dut","deg","tex","sur"
  ,"fel","tud","nux","rux","ren","wyt","nub","med","lyt","dus","neb","rum"
  ,"tyn","seg","lyx","pun","res","red","fun","rev","ref","mec","ted","rus"
  ,"bex","leb","dux","ryn","num","pyx","ryg","ryx","fep","tyr","tus","tyc"
  ,"leg","nem","fer","mer","ten","lus","nus","syl","tec","mex","pub","rym"
  ,"tuc","fyl","lep","deb","ber","mug","hut","tun","byl","sud","pem","dev"
  ,"lur","def","bus","bep","run","mel","pex","dyt","byt","typ","lev","myl"
  ,"wed","duc","fur","fex","nul","luc","len","ner","lex","rup","ned","lec"
  ,"ryd","lyd","fen","wel","nyd","hus","rel","rud","nes","hes","fet","des"
  ,"ret","dun","ler","nyr","seb","hul","ryl","lud","rem","lys","fyn","wer"
  ,"ryc","sug","nys","nyl","lyn","dyn","dem","lux","fed","sed","bec","mun"
  ,"lyr","tes","mud","nyt","byr","sen","weg","fyr","mur","tel","rep","teg"
  ,"pec","nel","nev","fes"]

rsh :: Integral a => a -> a -> a -> a
rsh a b c = c `div` 2 ^ (2 ^ a * b)

met :: Integral a => a -> a -> a
met = loop 0 where
  loop !acc a b
    | b == 0    = acc
    | otherwise = loop (succ acc) a (rsh a 1 b)

internalErr :: String -> String -> a
internalErr fn msg = error $ mconcat
  [ "urbit-hob ("
  , fn
  , "): internal error -- please report this as a bug!\n"
  , msg
  ]


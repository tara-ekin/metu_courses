module PE4 where

import Data.Maybe -- up to you if you want to use it or not

-- Generic DictTree definition with two type arguments
data DictTree k v = Node [(k, DictTree k v)] | Leaf v deriving Show

-- Lightweight Char wrapper as a 'safe' Digit type
newtype Digit = Digit Char deriving (Show, Eq, Ord) -- derive equality and comparison too!

-- Type aliases
type DigitTree = DictTree Digit String
type PhoneNumber = [Digit]


---------------------------------------------------------------------------------------------
------------------------- DO NOT CHANGE ABOVE OR FUNCTION SIGNATURES-------------------------
--------------- DUMMY IMPLEMENTATIONS ARE GIVEN TO PROVIDE A COMPILABLE TEMPLATE ------------
--------------------- REPLACE THEM WITH YOUR COMPILABLE IMPLEMENTATIONS ---------------------
---------------------------------------------------------------------------------------------


----------
-- Part I:
-- Some Maybe fun! Basic practice with an existing custom datatype.

-- toDigit: Safely convert a character to a digit
toDigit :: Char -> Maybe Digit
toDigit c = if not (elem c ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'])
               then Nothing
               else Just (Digit c)
                                   
-- toDigits: Safely convert a bunch of characters to a list of digits.
--           Particularly, an empty string should fail.
containsNonDigit :: String -> Bool
containsNonDigit s = if elem False [elem x ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'] | x <- s]
                        then True
                        else False
                        
toDigits :: String -> Maybe PhoneNumber
toDigits "" = Nothing
toDigits s = if containsNonDigit s 
                then Nothing
                else Just [Digit x | x <- s]

-----------
-- Part II:
-- Some phonebook business.

-- numContacts: Count the number of contacts in the phonebook...
eraseDigit :: (Digit, DigitTree) -> DigitTree
eraseDigit (Digit _, others) = others

contactCounter :: DigitTree -> Int -> Int
contactCounter (Leaf _) num = num + 1
contactCounter (Node [(Digit _, innerTree)]) num = contactCounter (innerTree) (num)
contactCounter (Node innerTree) num = contactCounter (eraseDigit (head innerTree)) (num) + contactCounter (Node (tail innerTree)) (num)
    
numContacts :: DigitTree -> Int
numContacts inp = contactCounter inp 0
    
-- getContacts: Generate the contacts and their phone numbers in order given a tree. 
digitCollector :: DigitTree -> [Digit] -> [([Digit], String)]
digitCollector (Leaf name) digitList = [(digitList, name)]
digitCollector (Node [(Digit a, innerTree)]) digitList = digitCollector (innerTree) (digitList ++ [Digit a])
digitCollector (Node innerTree) digitList = digitCollector (Node [(head innerTree)]) digitList ++ digitCollector (Node (tail innerTree)) digitList

getContacts :: DigitTree -> [(PhoneNumber, String)]
getContacts inp = digitCollector inp []

-- autocomplete: Create an autocomplete list of contacts given a prefix
-- e.g. autocomplete "32" areaCodes -> 
--      [([Digit '2'], "Adana"), ([Digit '6'], "Hatay"), ([Digit '8'], "Osmaniye")]
stringToDigits :: String -> [Digit]
stringToDigits s = [Digit x | x <- s]
                                                  
findInnerTree :: [Digit] -> DigitTree -> [DigitTree]
findInnerTree [] tree = [(Node [(Digit 'N', Leaf "")])]
findInnerTree x (Node [(d, Leaf l)]) = if (length x == 1) && (head x == d)
                                                then [Node [(d, Leaf l)]]
                                                else [Node [(Digit 'N', Leaf "")]]
findInnerTree x (Node [(d, innerTree)]) = if (head x == d) && (length x == 1) 
                                             then [innerTree] 
                                             else if (head x == d)
                                                     then findInnerTree (tail x) (innerTree)
                                                     else [Node [(Digit 'N', Leaf "")]]
findInnerTree x (Node innerTree) = findInnerTree x (Node [(head innerTree)]) ++ findInnerTree x (Node (tail innerTree))

notEmpty :: DigitTree -> Bool
notEmpty (Node [(d, _)]) = d /= (Digit 'N')

notEmpty2 :: [([Digit], String)] -> Bool
notEmpty2 inp = inp /= [([Digit 'N'],"")]

listNames :: [DigitTree] -> [[(PhoneNumber, String)]]
listNames trees = (filter notEmpty2 [getContacts x | x <- trees])

takeHead :: [[(PhoneNumber, String)]] -> [(PhoneNumber, String)]
takeHead phones = if (length phones > 0) then head phones
                                         else []

autocomplete :: String -> DigitTree -> [(PhoneNumber, String)]
autocomplete s tree = takeHead (listNames (findInnerTree (stringToDigits s) tree))


-----------
-- Example Trees
-- Two example trees to play around with, including THE exampleTree from the text. 
-- Feel free to delete these or change their names or whatever!

exampleTree :: DigitTree
exampleTree = Node [
    (Digit '1', Node [
        (Digit '3', Node [
            (Digit '7', Node [
                (Digit '8', Leaf "Jones")])]),
        (Digit '5', Leaf "Steele"),
        (Digit '9', Node [
            (Digit '1', Leaf "Marlow"),
            (Digit '2', Node [
                (Digit '3', Leaf "Stewart")])])]),
    (Digit '3', Leaf "Church"),
    (Digit '7', Node [
        (Digit '2', Leaf "Curry"),
        (Digit '7', Leaf "Hughes")])]

areaCodes :: DigitTree
areaCodes = Node [
    (Digit '3', Node [
        (Digit '1', Node [
            (Digit '2', Leaf "Ankara")]),
        (Digit '2', Node [
            (Digit '2', Leaf "Adana"),
            (Digit '6', Leaf "Hatay"),
            (Digit '8', Leaf "Osmaniye")])]),
    (Digit '4', Node [
        (Digit '6', Node [
            (Digit '6', Leaf "Artvin")])])]


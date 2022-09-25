import Text.Printf

-- Defining some constants used in the assignment
g = 666  -- The primitive root
p = 6661 -- The chosen prime number

-- Defining some helping functions
bruteforceSecretKey :: Integer -> Integer -> Integer -> Integer
bruteforceSecretKey base prime pk = bruteforceSecretKey' 0 where 
  bruteforceSecretKey' current =
    if (base ^ current) `mod` prime == pk 
      then current
      else bruteforceSecretKey' (succ current)
      
main :: IO Integer
main = do

  -----------------------------------------------------------------------------
  -- Assignment 1
  -----------------------------------------------------------------------------

  -- Alice wants to send Bob a confidential message and so this assignment 
  -- starts with Bob providing Alice with a public key.
  let bobPK = 2227

  -- Alice generates her own SK and PK before sending the message to Bob
  let aliceSK = 414
  let alicePK = (g ^ aliceSK) `mod` p

  let message = 2000
  let messageEncrypted = (bobPK ^ aliceSK) * message

  -- Alice now sends the pair C = (alicePK, messageEncrypted) to Bob
  let (c1, c2) = (alicePK, messageEncrypted)

  -----------------------------------------------------------------------------
  -- Assignment 2
  -----------------------------------------------------------------------------

  -- Eve have not intercepted the encrypted message and will now attempt
  -- to find the secret key of Bob to reconstruct Alice message

  -- Eve can find Bob's secret key by making a brute force attack on his
  -- public key
  let bobSKBroken = bruteforceSecretKey g p bobPK
  -- Eve also needs to find out the secret key of alice
  let aliceSKBroken = bruteforceSecretKey g p c1
  -- Now Eve can proceed to decrypt the message
  let messageDecrypted = messageEncrypted `div` (g ^ bobSKBroken)
  printf "Eve decrypts the intercepted message to: %s\n" (show messageDecrypted)



  return 0

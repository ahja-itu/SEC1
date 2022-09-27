import Text.Printf

-- Defining some helping functions
bruteforceSecretKey :: Integer -> Integer -> Integer -> Integer
bruteforceSecretKey base prime pk = bruteforceSecretKey' 0 where 
  bruteforceSecretKey' current =
    if ((base ^ current) `mod` prime) == pk 
      then current
      else bruteforceSecretKey' (succ current)
      
createKey :: Integer -> Integer -> Integer -> Integer
createKey base exponent prime = (base ^ exponent) `mod` prime

encryptMsg :: Integer -> Integer -> Integer
encryptMsg sharedKey msg = sharedKey * msg

decryptMsg :: Integer -> Integer -> Integer
decryptMsg sharedKey msg = msg `div` sharedKey


assignment1 :: Integer -> Integer -> Integer -> IO (Integer, Integer)
assignment1 p g pkb = do
  -- Alice wants to send Bob a confidential message and so this assignment 
  -- starts with Bob providing Alice with a public key.

  -- This is the message that Alice wants to send to Bob
  let message = 2000

  -- Alice generates her own SK and PK to in order to generate the shared key
  let ska = 414
  let pka = createKey g ska p
  printf "Alice generates her SK/PK pair: (%s, %s)\n" (show ska) (show pka)

  let sharedKey = createKey pkb ska p
  printf "Alice generates the shared key: %s\n" (show sharedKey)

  let messageEncrypted = encryptMsg sharedKey message
  printf "Alice encrypts the message \"%s\": %s\n" (show message) (show messageEncrypted)

  -- Alice now sends the pair C = (alicePK, messageEncrypted) to Bob
  putStrLn "*** Alice sends the message to Bob ***"

  -- This is the message sent to Bob (that _someone_ might be able to intercept ;-))
  return (pka, messageEncrypted)


assignment2 :: Integer -> Integer -> Integer -> (Integer, Integer) -> IO ()
assignment2 p g pkb (c1, c2) = do
  -- Eve have now intercepted the encrypted message and will now attempt
  -- to find the secret key of Bob to reconstruct Alice message

  -- Eve can find Bob's secret key by making a brute force attack on his
  -- public key
  let bobSKBroken = bruteforceSecretKey g p pkb
  printf "Eve intercepts the messages and finds Bob's secret key by brute force: %s\n" (show bobSKBroken)
  -- Eve also needs to find out the secret key of alice
  let brokenSharedKey = createKey c1 bobSKBroken p
  printf "Eve generates the shared key that was used to decrypt the message with: %s\n" (show brokenSharedKey)
  -- Now Eve can proceed to decrypt the message
  let messageDecrypted = decryptMsg brokenSharedKey c2
  printf "Eve decrypts the intercepted message to: %s\n" (show messageDecrypted)

  return ()

assignment3 :: (Integer, Integer) -> IO (Integer, Integer)
assignment3 (c1, c2) = do
  -- This funciton only reflects the actions that Mallory takes. This function returns
  -- The tampered message for Bob to decrypt
  putStrLn "Mallory intercepts the message going from Alice to Bob."
  putStrLn "Mallory alters the message and sends it along to Bob."

  let c2' = c2 * 3
  return (c1, c2')


bobDecryptsMsg :: Integer -> Integer -> Integer -> (Integer, Integer) -> IO Integer
bobDecryptsMsg p g pkb (c1, c2) = do
  let skb = bruteforceSecretKey g p pkb
  let sharedKey = createKey c1 skb p
  return (decryptMsg sharedKey c2)
  

main :: IO Integer
main = do
  -----------------------------------------------------------------------------
  -- Assignment 1
  -----------------------------------------------------------------------------
  putStrLn "########## Assignment 1 ##########"

  -- Alice wants to send Bob a confidential message. Bob provides Alice with 
  -- his secret key, consisting of the generator g, prime p and his public
  -- encryption key
  let (p, g, pkb) = (6661, 666, 2227)

  -- Solving assignment 1 within function `assignment1` to only reveal the 
  -- message that will be sent to Bob
  c <- assignment1 p g pkb


  -----------------------------------------------------------------------------
  -- Assignment 2
  -----------------------------------------------------------------------------
  putStrLn ""
  putStrLn "########## Assignment 2 ##########"

  assignment2 p g pkb c
  
  -----------------------------------------------------------------------------
  -- Assignment 3
  -----------------------------------------------------------------------------
  putStrLn ""
  putStrLn "########## Assignment 3 ##########"
  

  (c1, c2) <- assignment3 c

  printf "Bob now receives the tampered message C = (%s, %s)\n" (show c1) (show c2)
  -- Bob decrypts the message with the shared key (Bob can generate this, but we'll
  -- use the previously generated one from Alice for convenience)
  tamperedMessageDecrypted <- bobDecryptsMsg p g pkb (c1, c2)

  printf "Bob decrypts the tampered message into: %s\n" (show tamperedMessageDecrypted)

  return 0

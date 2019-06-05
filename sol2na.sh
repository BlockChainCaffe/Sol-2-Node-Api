#!/bin/bash
#
#   Solidity to NodeJS Express API
#
# ------------------------------------------------------------------------------


function genericCall {

echo "app.get(\"/"$FUNC"\", (req,rep)=> {"

# split string into array
IFS=',' read -r -a INPUTS <<< "$PARAMS"
# iterate params
for INPUT in "${INPUTS[@]}"
do
    I=$(echo "$INPUT" | sed "s:^ *::g" | sed "s: *$::g" | sed "s:  *: :g")
    TYPE=$(echo "$I" |cut -d ' ' -f 1)
    NAME=$(echo "$I" |cut -d ' ' -f 2 | tr -d "_ " )
    echo "    var "$NAME" = req.query."$NAME" //"$TYPE
done

echo "    var input"
echo "    contract."$FUNC"( input, (err, res) {"
echo "      if ( err !== null ) {"
echo "          console.log(err)"
echo "          rep.status(500)"
echo "          rep.json({"message": err})"
echo "      } else {"
echo "            console.log(\"res: \" + res)"
echo "            var obj = {}"

# split string into array
IFS=',' read -r -a VALUES <<< "$RETURNS"
# iterate params
for VALUE in "${VALUES[@]}"
do
    V=$(echo "$VALUE" | sed "s:^ *::g" | sed "s: *$::g" | sed "s:  *: :g")
    TYPE=$(echo "$V" | sed "s:  *: :g" | cut -d ' ' -f 1)
    NAME=$(echo "$V" | sed "s:  *: :g" | cut -d ' ' -f 2)
    echo "            obj."$NAME" = 1 // "$TYPE
done

echo "            rep.status(200).json(obj)"
echo "      }"
echo "    }"
echo "})"  
echo 
}



function genericTransaction {
echo "app.post(\"/"$FUNC"\", (req,rep)=> {"

# split string into array
IFS=',' read -r -a INPUTS <<< "$PARAMS"
# iterate params
for INPUT in "${INPUTS[@]}"
do
    I=$(echo "$INPUT" | sed "s:^ *::g" | sed "s: *$::g" | sed "s:  *: :g")
    TYPE=$(echo "$I" |cut -d ' ' -f 1)
    NAME=$(echo "$I" |cut -d ' ' -f 2 | tr -d "_ " )
    echo "    var "$NAME" = req.body."$NAME" //"$TYPE
done

echo "    var input"
echo "    contract."$FUNC"( input, (err, res) {"
echo "      if ( err !== null ) {"
echo "          console.log(err)"
echo "          rep.status(500)"
echo "          rep.json({"message": err})"
echo "      } else {"
echo "            console.log(\"res: \" + res)"
echo "            var obj = {}"
echo "            rep.status(200).json(obj)"
echo "      }"
echo "    }"


echo "})"  
echo 
}

# ------------------------------------------------------------------------------
C=$1
OUT="route_"
 
## Process all CALLS (not transactions)
cat $C | egrep "^[ \t]*function " | grep "returns" | grep "public\|external\|view"> $OUT-2
while read line; do 
    # Get method name
    FUNC=$(echo $line | sed "s:^.*function::" | sed "s:^ ::g" | sed "s:[ (].*$::")
    # Passed Parameters (as query string?)
    PARAMS=$(echo $line | sed "s:).*$::" | sed "s:^.*(::" )
    # Get List of return values
    RETURNS=$(echo $line | sed "s:^.*returns::" | sed "s:).*$::" | sed "s: *::" | sed "s:(::")
    genericCall
done < $OUT-2


## Process all TRANSACTIONS
cat $C | egrep "^[ \t]*function " | grep -v "returns" | grep -v "internal"  > $OUT-2
while read line; do 
    # Get method name
    FUNC=$(echo $line | sed "s:^.*function::" | sed "s:^ ::g" | sed "s:[ (].*$::")
    # Passed Parameters (as request body?)
    PARAMS=$(echo $line | sed "s:).*$::" | sed "s:^.*(::" )

    genericTransaction 

done < $OUT-2


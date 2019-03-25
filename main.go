 package main

 import (
	 "flag"
	 "fmt"
	 "io/ioutil"
	 "log"
	 "net/http"
	 "net/url"
	 "strings"
 )
 
 var (
	 // flagPort is the open port the application listens on
	 flagPort = flag.String("port", "9000", "Port to listen on")
 )
 
 // PostHandler converts post request body to string
 func PostHandler(w http.ResponseWriter, r *http.Request) {

	 // Set initial variables
	 accountSid := "ACb5e52d7d1132796713ba949153359e67"
	 authToken := "2fcc5e58a80375d4c6a574979f274c8a"
	 urlStr := "https://api.twilio.com/2010-04-01/Accounts/" + accountSid + "/Messages.json"

	if r.Method == "POST" {
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.Println(err)
		}

	 // Build out the data for our message
	 v := url.Values{}
	 v.Set("To","+447835217316")
	 v.Set("From","+447479275693")
	 v.Set("Body", string(body))
	 rb := *strings.NewReader(v.Encode())

	 fmt.Println(rb)
   
	 // Create client
	 client := &http.Client{}
   
	 req, _ := http.NewRequest("POST", urlStr, &rb)
	 req.SetBasicAuth(accountSid, authToken)
	 req.Header.Add("Accept", "application/json")
	 req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
   
	 // Make request
	 resp, _ := client.Do(req)
	 fmt.Println(resp.Status)
	}
 }
 
 func init() {
	 log.SetFlags(log.Lmicroseconds | log.Lshortfile)
	 flag.Parse()
 }
 
 func main() {
 
	 mux := http.NewServeMux()
	 mux.HandleFunc("/", PostHandler)
	 log.Printf("listening on port %s", *flagPort)
	 log.Fatal(http.ListenAndServe(":"+*flagPort, mux))
 }
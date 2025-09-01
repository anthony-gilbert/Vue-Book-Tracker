package main

import (
	"fmt"
	"net/http"
)

func main() {
	// Define an HTTP handler function for serving the HTML page
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Set the content type to HTML
		w.Header().Set("Content-Type", "text/html")

		// Write the HTML content to the response
		htmlContent := `
			<!DOCTYPE html>
			<html>
			<head>
				<title>Sample HTML Page</title>
			</head>
			<body>
				<h1>Hello, World</h1>
				<p>This is a sample HTML page served by a Go HTTP server.</p>
			</body>
			</html>
		`
		fmt.Fprintln(w, htmlContent)
	})

	// Start the HTTP server on port 8080
	fmt.Println("Server listening on :8080")
	http.ListenAndServe(":8080", nil)
}

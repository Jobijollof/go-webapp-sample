# Use the official Go base image
FROM golang:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Go modules files
COPY go.mod go.sum ./

# Download and install the application dependencies
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the Go application
RUN go build -o myapp

# Expose the port on which your application listens
EXPOSE 8080

# Set the entry point for the container
CMD ["./myapp"]

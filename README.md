# Web Timer

## Getting Started

1. Install dependencies

        npm install
        bower install

2. Run tests and build extension

        grunt

3. Load unpacked extension in `chrome://extensions`

## Running Tests

### background.js Tests

1. Build extension with tests

        grunt build:test

2. Navigate to `chrome-extension://<extension-id>/spec/background/runner.html` to run unit tests

### Angular Tests

     grunt test

## Demo Video


[Watch the video](https://vimeo.com/980035926)

# CurrencySwift

CurrencySwift is an iOS application for real-time currency conversion. It leverages the latest SwiftUI framework to provide a modern and responsive user interface. The app is designed with a clean and intuitive layout, allowing users to easily convert between different currencies and view up-to-date exchange rates.

## Features

- Real-time currency conversion
- Search and select base currency
- Enter and convert custom amounts
- Mark favorite currencies for quick access
- Light and dark mode support
- Adaptive UI for different themes

## Frameworks and Libraries Used

### SwiftUI
### Combine
### URLSession
### ExchangeRate-API


## Getting Started


### Installation

1. Clone the repository
   ```
   git clone https://github.com/yourusername/CurrencySwift.git
   ```
2. Open the project in Xcode
   ```
   cd CurrencySwift
   open CurrencySwift.xcodeproj
   ```

3. Set up your API key
   - Rename `Secrets.template.swift` to `Secrets.swift`
   - Add your API key in `Secrets.swift`
     ```swift
     struct Secrets {
         static let apiKey = "YOUR_API_KEY_HERE"
     }
     ```

### Running the App
1. Select the target device or simulator.
2. Build and run the project using Xcode's play button or `Cmd + R`.

## Project Structure

- **ViewModels**: Contains view models that manage the data and business logic of the app.
- **Views**: Contains SwiftUI views which define the user interface.
- **Services**: Contains services responsible for fetching data from the API.
- **Models**: Contains the data models representing the currency data.
- **Resources**: Contains assets like images and any other resources.

## Roadmap

CurrencySwift is still in development, and here are some of the planned features:

- Improved error handling and user feedback
- Historical exchange rate charts
- Multi-language support
- User authentication for saving settings across devices

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a pull request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Thanks to [ExchangeRate-API](https://www.exchangerate-api.com) for providing the exchange rate data.

---

**Note**: This project is under active development. Features and UI are subject to change as development progresses.



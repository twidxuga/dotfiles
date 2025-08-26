import json
import sys
import requests

TOOL_NAME = "get_weather"

def get_weather(latitude, longitude):
    """Fetches weather information from the Open-Meteo API."""
    url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true"
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for bad status codes
        return response.json()
    except requests.exceptions.RequestException as e:
        return {"error": str(e)}

def main():
    """Main function to handle tool calls."""
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name")

        if tool_name == TOOL_NAME:
            tool_input = input_data.get("tool_input", {})
            latitude = tool_input.get("latitude")
            longitude = tool_input.get("longitude")

            if latitude is not None and longitude is not None:
                weather_data = get_weather(latitude, longitude)
                print(json.dumps(weather_data))
            else:
                print(json.dumps({"error": "Latitude and longitude are required."}))
        else:
            print(json.dumps({"error": f"Unknown tool: {tool_name}"}))

    except json.JSONDecodeError:
        print(json.dumps({"error": "Invalid JSON input."}))
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    main()


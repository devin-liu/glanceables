# Glanceables


https://github.com/user-attachments/assets/497c6596-4c36-4baa-b710-b9213e20affd



## Overview
We're aiming to make the web simpler one widget at a time with our unique approach: "A browser that's not a browser." This means transforming complex websites into easy-to-digest widgets. You get just the essentials—whether that’s watching for price changes, checking if there’s space at the campground, or updating the traffic situation—without the need to keep refreshing pages.

## The Problem We're Solving
Ever feel like the internet's a crowded room, shouting at you from every corner? It’s packed with ads and complicated layouts that make finding what you need harder than finding a needle in a haystack. Our project is here to change that by stripping down to the basics and making your digital life as easy as pie. We’re bringing the joy back to browsing—no hassle, just the good stuff.

## Precision Capture and Restoration
Our web clip capture & restoring algorithm enhances precise selection and automatic recovery of web content. This is for users who need to monitor specific areas of a webpage with high accuracy.

<img width="1136" alt="Screenshot 2024-07-22 at 11 16 53 AM" src="https://github.com/user-attachments/assets/32b4ed7f-cdbf-4145-bfbf-af767a8a69e6">

### How It Works
- **Interactive Selection:** Users can manually select an area on the webpage by dragging a 300px by 300px rectangle. This can be done anywhere on the webpage to focus on content that matters.
- **Element Detection and Selection:** Once an area is selected, our algorithm detects all elements within the center of the rectangle. It then filters these elements to include only those that are fully or partially inside the selected area.
- **Data Capture and Storage:** For each detected element, a unique CSS selector is generated. We record this selector along with the element’s position relative to the scroll position at the time of capture, ensuring detailed and precise information storage.
- **Boundary Restoration:** When accessing the widget again, the system uses the stored CSS selector to locate the element and adjusts the webpage's scroll to the original position, perfectly restoring the view to its previous state.

### Auto-Refresh
To ensure you are viewing the most current information, webpages within Glanceables refresh automatically every 60 seconds.

### How to Run
1. This project requires [Ollama](https://ollama.com/download) for local LLM integration, please download that first.
2. Go to the [releases page](https://github.com/devin-liu/glanceables/releases) and download the latest version.
3. Add your first glanceable by following the interactive guide on our application.


## How to Help Out
- **Report Issues:** Stumbled upon a problem or have a suggestion? Pop it into our issues section.
- **Make Improvements:** Have a fix or a new feature? We welcome your pull requests.
- **Share Your Thoughts:** Your feedback drives our improvement, so don’t hesitate to reach out.

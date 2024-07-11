# Glanceables
<img width="1136" alt="Screenshot 2024-07-11 at 4 15 39 PM" src="https://github.com/user-attachments/assets/cd8d73ce-aeb3-4d7f-8b66-ec9dd5278bb9">


## Overview
We're aiming to make the web simpler one widget at a time with our unique approach: "A browser that's not a browser." This means transforming complex websites into easy-to-digest widgets. You get just the essentials—whether that’s watching for price changes, checking if there’s space at the campground, or updating the traffic situation—without the need to keep refreshing pages.

## The Problem We're Solving
Ever feel like the internet's a crowded room, shouting at you from every corner? It’s packed with ads and complicated layouts that make finding what you need harder than finding a needle in a haystack. Our project is here to change that by stripping down to the basics and making your digital life as easy as pie. We’re bringing the joy back to browsing—no hassle, just the good stuff.

## Precision Capture and Restoration
Our web clip capture & restoring algorithm enhances precise selection and automatic recovery of web content. This is for users who need to monitor specific areas of a webpage with high accuracy.

### How It Works
- **Interactive Selection:** Users can manually select an area on the webpage by dragging a 300px by 300px rectangle. This can be done anywhere on the webpage to focus on content that matters.
- **Element Detection and Selection:** Once an area is selected, our algorithm detects all elements within the center of the rectangle. It then filters these elements to include only those that are fully or partially inside the selected area.
- **Data Capture and Storage:** For each detected element, a unique CSS selector is generated. We record this selector along with the element’s position relative to the scroll position at the time of capture, ensuring detailed and precise information storage.
- **Boundary Restoration:** When accessing the widget again, the system uses the stored CSS selector to locate the element and adjusts the webpage's scroll to the original position, perfectly restoring the view to its previous state.

### Auto-Refresh
To ensure you are viewing the most current information, webpages within Glanceables refresh automatically every 60 seconds.

## How to Help Out
- **Report Issues:** Stumbled upon a problem or have a suggestion? Pop it into our issues section.
- **Make Improvements:** Have a fix or a new feature? We welcome your pull requests.
- **Share Your Thoughts:** Your feedback drives our improvement, so don’t hesitate to reach out.

function getElementPosition(element) {
    const rect = element.getBoundingClientRect();
    return {
        relativeTop: rect.top - window.scrollY,
        relativeLeft: rect.left - window.scrollX
    };
}


function getUniqueSelector(element) {
    if (!element) return null;

    let path = "", current = element;
    while (current && current !== document.body && current.nodeType === Node.ELEMENT_NODE) { // Stop at body element
        let selector = current.nodeName.toLowerCase();
        
        // Use attribute selector for ID
        if (current.id) {
            selector += `[id='${current.id}']`; // Updated line
            path = selector + (path ? " > " + path : "");
            break; // ID is unique enough for a selector
        }

        const classList = Array.from(current.classList);
        if (classList.length > 0) {
            selector += '.' + classList.join('.');
        }

        let sibling = current;
        let nth = 1;
        while (sibling = sibling.previousElementSibling) {
            if (sibling.nodeName.toLowerCase() === current.nodeName.toLowerCase()) {
                nth++;
            }
        }
        if (nth > 1) {
            selector += `:nth-of-type(${nth})`;
        }

        path = selector + (path ? " > " + path : "");
        current = current.parentElement;
    }
    return path;
}


function getElementsWithinBoundary(x, y) {
    const elements = document.elementsFromPoint(x, y);
    const boundarySize = 300;
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;

    // Adjust boundary values to not exceed viewport dimensions or fall below 0
    const xMin = Math.max(0, x - boundarySize);
    const xMax = Math.min(viewportWidth, x + boundarySize);
    const yMin = Math.max(0, y - boundarySize);
    const yMax = Math.min(viewportHeight, y + boundarySize);

    return elements.filter(element => {
         const rect = element.getBoundingClientRect();
         // Check if there is any overlap between the element's bounding box and the adjusted boundaries
         return (rect.left <= xMax && rect.right >= xMin) && (rect.top <= yMax && rect.bottom >= yMin);
     });
}


function getElementsFromSelectors(selectors) {
    let elements = [];
    selectors.forEach(selector => {
        const element = document.querySelector(selector);
        if (element) {
            elements.push(element);
        } else {
            console.log(`No element found for selector: ${selector}`);
        }
    });
    return elements;
}

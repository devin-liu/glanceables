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
    const boundarySize = 150;
    const yMin = y - boundarySize;
    const yMax = y + boundarySize;
    
    return elements.filter(element => {
        const rect = element.getBoundingClientRect();
        
        // Check if the vertical position of the element is within the boundary
        const isTopWithinBoundary = rect.top >= yMin && rect.top <= yMax;
        const isBottomWithinBoundary = rect.bottom >= yMin && rect.bottom <= yMax;
        
        // Allow elements where either the top or bottom is within the vertical boundary
        return (isTopWithinBoundary || isBottomWithinBoundary);
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

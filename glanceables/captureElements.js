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
        if (current.id) {
            selector += `#${current.id}`;
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
    const xMin = x - boundarySize;
    const xMax = x + boundarySize;
    const yMin = y - boundarySize;
    const yMax = y + boundarySize;

    return elements.filter(element => {
        const rect = element.getBoundingClientRect();
        return rect.left >= xMin && rect.right <= xMax && rect.top >= yMin && rect.bottom <= yMax;
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

function showQRCode() {
    // Display the QR code modal
    document.getElementById('qrCodeModal').style.display = 'block';
    
    // Set a timeout to check if the QR code has been scanned after 10 seconds
    setTimeout(checkQRCodeScanned, 10000);
}

function closeQRCodeModal() {
    // Close the QR code modal
    document.getElementById('qrCodeModal').style.display = 'none';
}

function checkQRCodeScanned() {
    // Check if the QR code has been scanned (replace this with your actual QR code scanning logic)
    const qrCodeScanned = confirm('Did you scan the QR code?');

    if (qrCodeScanned) {
        // If QR code is scanned, submit the form
        document.getElementById('orderForm').submit();
    } else {
        // If QR code is not scanned, close the modal (optional)
        closeQRCodeModal();
    }
}
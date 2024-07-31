-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 14, 2024 at 05:26 PM
-- Server version: 10.4.25-MariaDB
-- PHP Version: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `gothamtreats`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `authenticateUser` (IN `p_username` VARCHAR(255), IN `p_password` VARCHAR(255))   BEGIN
    DECLARE v_customerID VARCHAR(255);

    SELECT customerID
    INTO v_customerID
    FROM customer
    WHERE username = p_username AND password = p_password;

    IF v_customerID IS NOT NULL THEN
        SELECT v_customerID AS result;
    ELSE
        SELECT 'Authentication Failed' AS result;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createDelivery` (IN `p_deliveryID` VARCHAR(20), IN `p_orderID` VARCHAR(20), IN `p_outletID` VARCHAR(20), IN `p_deliveryType` VARCHAR(20), IN `p_deliveryAddress` VARCHAR(255))   BEGIN
    INSERT INTO gothamtreats.delivery (
        deliveryID,
        orderID,
        outletID,
        deliveryType,
        deliveryAddress,
        deliveryFee,
        deliveryStatus
    ) VALUES (
        p_deliveryID,
        p_orderID,
        p_outletID,
        p_deliveryType,
        p_deliveryAddress,
        25000,
        'Pending'
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createOrder` (IN `p_customerID` VARCHAR(20), IN `p_voucherID` VARCHAR(20), IN `p_productID` VARCHAR(20), IN `p_quantityOrdered` INT, IN `p_notes` VARCHAR(255), IN `p_outletID` VARCHAR(20), IN `p_deliveryAddress` VARCHAR(255))   BEGIN
    DECLARE p_orderCode INT;
    DECLARE p_orderID VARCHAR(20);
    DECLARE p_paymentID VARCHAR(20);
    DECLARE p_deliveryID VARCHAR(20);
    DECLARE p_productPrice DOUBLE;
    DECLARE p_orderTotalPrice DOUBLE;
    DECLARE p_discountPercentage DOUBLE DEFAULT 0;
    DECLARE p_orderTotalAfterDiscount DOUBLE;
    DECLARE p_orderTotalPayment DOUBLE;

    -- Get the product price based on the provided p_productID
    SELECT productPrice INTO p_productPrice
    FROM gothamtreats.product
    WHERE productID = p_productID;

    -- Calculate the order total price
    SET p_orderTotalPrice = p_productPrice * p_quantityOrdered;

    -- Validate the voucher before applying it
    IF p_voucherID IS NOT NULL THEN
        -- Check if the voucher is valid and get its discount percentage
        SELECT `discountPercentage`
        INTO p_discountPercentage
        FROM `gothamtreats`.`voucher`
        WHERE `voucherID` = p_voucherID AND `voucherStatus` = 'Activated';
    ELSE
        -- If no voucher is provided, set discountPercentage to 0
        SET p_discountPercentage = 0;
    END IF;

    -- Calculate total after discount
    SET p_orderTotalAfterDiscount = p_orderTotalPrice * (1 - p_discountPercentage / 100);

    -- Insert order details and get the auto-incremented orderCode
    INSERT INTO gothamtreats.order (
        customerID,
        voucherID,
        paymentID,
        orderDateTime,
        orderStatus,
        orderTotalPrice,
        orderTotalAfterDiscount,
        discountPercentage
    ) VALUES (
        p_customerID,
        p_voucherID,
        '',
        NOW(),
        'Processing',
        p_orderTotalPrice,
        p_orderTotalAfterDiscount,
        p_discountPercentage
    );

    -- Get the auto-incremented orderCode
    SELECT LAST_INSERT_ID() INTO p_orderCode;

    -- Generate orderID, paymentID, and deliveryID
    SET p_orderID = CONCAT('O', p_orderCode);
    SET p_paymentID = CONCAT('P', p_orderCode);
    SET p_deliveryID = CONCAT('D', p_orderCode);

    -- Update order details with the generated orderID and orderTotalAfterDiscount
    UPDATE gothamtreats.order
    SET orderID = p_orderID,
        paymentID = p_paymentID
    WHERE orderCode = p_orderCode;

    -- Call createOrderDetail to add order details
    CALL createOrderDetail(p_orderID, p_productID, p_quantityOrdered, p_notes);

    -- Calculate the total payment including an additional 25000 and the orderTotalAfterDiscount
    SET p_orderTotalPayment = p_orderTotalAfterDiscount + 25000;

    -- Call createPayment to add payment details
    CALL createPayment(p_paymentID, p_orderTotalPayment);

    -- Call createDelivery to add delivery details
    CALL createDelivery(p_deliveryID, p_orderID, p_outletID, 'Standard', p_deliveryAddress);

    -- Update the flag in OrderFlagTable to indicate that an order has been created
    UPDATE OrderFlagTable SET orderID_created = p_orderID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createOrderDetail` (IN `p_orderID` VARCHAR(20), IN `p_productID` VARCHAR(20), IN `p_quantityOrdered` INT, IN `p_notes` VARCHAR(255))   BEGIN
    -- Insert order detail
    INSERT INTO orderdetail (
        orderID,
        productID,
        quantityOrdered,
        notes
    ) VALUES (
        p_orderID,
        p_productID,
        p_quantityOrdered,
        p_notes
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createOrderFinal` (IN `p_customerID` VARCHAR(20), IN `p_voucherID` VARCHAR(20), IN `p_productsJSON` JSON, IN `p_outletID` VARCHAR(20), IN `p_deliveryAddress` VARCHAR(255))   BEGIN
    DECLARE p_orderCode VARCHAR(20);
    DECLARE p_orderID VARCHAR(20);
    DECLARE p_paymentID VARCHAR(20);
    DECLARE p_deliveryID VARCHAR(20);
    DECLARE p_productPrice DOUBLE;
    DECLARE p_orderTotalPrice DOUBLE DEFAULT 0;
    DECLARE p_discountPercentage DOUBLE DEFAULT 0;
    DECLARE p_orderTotalAfterDiscount DOUBLE;
    DECLARE p_orderTotalPayment DOUBLE;
    DECLARE v_index INT DEFAULT 0;
    DECLARE v_totalItems INT;

    DECLARE v_productID VARCHAR(20);
    DECLARE v_quantity INT;
    DECLARE v_note VARCHAR(255);

    -- Insert order details and get the auto-incremented orderCode
    INSERT INTO gothamtreats.order (
        customerID,
        voucherID,
        paymentID,
        orderDateTime,
        orderStatus,
        orderTotalPrice,
        orderTotalAfterDiscount,
        discountPercentage
    ) VALUES (
        p_customerID,
        p_voucherID,
        '',
        NOW(),
        'Processing',
        0,
        0,
        0
    );

    SELECT LAST_INSERT_ID() INTO p_orderCode;

    -- Generate orderID, paymentID, and deliveryID
    SET p_orderID = CONCAT('O', p_orderCode);
    SET p_paymentID = CONCAT('P', p_orderCode);
    SET p_deliveryID = CONCAT('D', p_orderCode);

    -- Update order details with the generated orderID and orderTotalAfterDiscount
    UPDATE gothamtreats.order
    SET orderID = p_orderID,
        paymentID = p_paymentID
    WHERE orderCode = p_orderCode;

  -- Validate the voucher before applying it
    IF p_voucherID IS NOT NULL THEN
        -- Check if the voucher is valid and get its discount percentage
        SELECT discountPercentage
        INTO p_discountPercentage
        FROM gothamtreats.voucher
        WHERE voucherID = p_voucherID AND voucherStatus = 'Activated';
    ELSE
        -- If no voucher is provided, set discountPercentage to 0
        SET p_discountPercentage = 0;
    END IF;

    -- Determine the number of items in the JSON array
    SET v_totalItems = JSON_LENGTH(p_productsJSON);

    -- Your existing code for calculating discounts and inserting into order table goes here

    -- Loop through the JSON array
    WHILE v_index < v_totalItems DO
        -- Extract productID, quantity, and note from the JSON object
        SET v_productID = JSON_UNQUOTE(JSON_EXTRACT(p_productsJSON, CONCAT('$[', v_index, '].productID')));
        SET v_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_productsJSON, CONCAT('$[', v_index, '].quantity')));
        SET v_note = JSON_UNQUOTE(JSON_EXTRACT(p_productsJSON, CONCAT('$[', v_index, '].note')));

        -- Calculate price for each product
        SELECT productPrice INTO p_productPrice
        FROM gothamtreats.product
        WHERE productID = v_productID;

        -- Add to total price
        SET p_orderTotalPrice = p_orderTotalPrice + (p_productPrice * v_quantity);

        -- Call createOrderDetail for each product
        CALL createOrderDetail(p_orderID, v_productID, v_quantity, v_note);
        SET v_index = v_index + 1;
    END WHILE;

    -- Continue with your existing code for payment and delivery details

    SET p_orderTotalAfterDiscount = p_orderTotalPrice * (1 - p_discountPercentage / 100);
    -- Update order with the final total price
    UPDATE gothamtreats.order
    SET orderTotalPrice = p_orderTotalPrice,
        orderTotalAfterDiscount = p_orderTotalPrice * (1 - p_discountPercentage / 100),
        discountPercentage = p_discountPercentage
    WHERE orderID = p_orderID;

    CALL createPayment(p_paymentID, p_orderTotalAfterDiscount + 25000);

    CALL createDelivery(p_deliveryID, p_orderID, p_outletID, 'Standard', p_deliveryAddress);

    UPDATE OrderFlagTable SET orderID_created = p_orderID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createPayment` (IN `p_paymentID` VARCHAR(20), IN `p_paymentAmount` DECIMAL(10,2))   BEGIN
    -- Insert payment details with paymentStatus set to 'Pending'
    INSERT INTO gothamtreats.payment (
        paymentID,
        paymentAmount,
        paymentDate,
        paymentType,
        paymentStatus
    ) VALUES (
        p_paymentID,
        p_paymentAmount,
        NOW(),
        'QRIS',
        'Pending'
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createUserData` (IN `p_username` VARCHAR(50), IN `p_password` VARCHAR(50), IN `p_fullName` VARCHAR(100), IN `p_email` VARCHAR(100), IN `p_phone` VARCHAR(20), IN `p_birthday` DATE, IN `p_address` VARCHAR(255))   BEGIN
DECLARE usernameExists INT;
DECLARE p_customerCode INT;
DECLARE p_customerID VARCHAR(20);

-- Check if the provided username already exists
SELECT COUNT(*) INTO usernameExists
FROM customer
WHERE username = p_username;

-- If the username exists, prompt the user to choose a different one
IF usernameExists > 0 THEN
SELECT 'Please choose a different username.' AS message;
ELSE
-- Insert the new customer data
INSERT INTO customer (
username,
password,
fullName,
email,
phone,
birthday,
address
) VALUES (
p_username,
p_password,
p_fullName,
p_email,
p_phone,
p_birthday,
p_address
);

-- Get the auto-incremented customerCode
SELECT LAST_INSERT_ID() INTO p_customerCode;

-- Generate customerID based on the auto-incremented customerCode
SET p_customerID = CONCAT('C', p_customerCode);

-- Update the customerID in the table
UPDATE customer
SET customerID = p_customerID
WHERE customerCode = p_customerCode;

SELECT 'Customer created successfully.' AS message;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readAllVoucherData` ()   BEGIN
    SELECT *
    FROM voucher;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readOrderData` (IN `p_orderID` VARCHAR(255))   BEGIN
SELECT 
    o.orderID, pr.productName, pr.productPrice, od.notes, 
    o.orderDateTime, o.orderStatus, o.orderTotalPrice,
    v.voucherCode, v.discountPercentages,
    d.deliveryFee, d.deliveryType,
    d.deliveryAddress, ol.outletLocation,
    od.quantityOrdered, p.paymentType, p.paymentDate
FROM `order` o
INNER JOIN voucher v ON o.voucherID = v.voucherID
INNER JOIN payment p ON o.paymentID = p.paymentID
INNER JOIN delivery d ON o.orderID = d.orderID
INNER JOIN outlet ol ON d.outletID = ol.outletID
INNER JOIN orderDetail od ON o.orderID = od.orderID
INNER JOIN product pr ON od.productID = pr.productID
WHERE o.orderID = p_orderID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readOutlet` (IN `p_outletID` VARCHAR(255))   BEGIN
    SELECT *
    FROM outlet
    WHERE outletID = p_outletID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readProductCategory` (IN `p_productCategory` ENUM('Cookie','DessertBox','Pudding','Coffee','Milk','Pie'))   BEGIN
    SELECT *
    FROM product
    WHERE productCategory = p_productCategory;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readProductDetail` (IN `p_productID` VARCHAR(255))   BEGIN
    SELECT *
    FROM product
    WHERE productID = p_productID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readUserData` (IN `p_customerID` VARCHAR(255))   BEGIN

    SELECT *
    FROM customer
    WHERE 
customerID = p_customerID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `readVoucher` (IN `p_voucherID` VARCHAR(255))   BEGIN
    SELECT *
    FROM voucher
    WHERE voucherID = p_voucherID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateDeliveryStatus` (IN `p_deliveryID` VARCHAR(255), IN `p_deliveryStatus` ENUM('Pending','Out for Delivery','Delivered'))   BEGIN
    UPDATE delivery
    SET deliveryStatus = p_deliveryStatus
    WHERE deliveryID = p_deliveryID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updatePasswordByEmail` (IN `email_param` VARCHAR(255), IN `new_password_param` VARCHAR(255))   BEGIN
    DECLARE user_count INT;

    -- Check if the email exists in the customers table
    SELECT COUNT(*) INTO user_count FROM customer WHERE email = email_param;

    -- If the email exists, update the password
    IF user_count > 0 THEN
        UPDATE customer SET password = new_password_param WHERE email = email_param;
        SELECT 'Password updated successfully' AS message;
    ELSE
        SELECT 'Email not found' AS message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updatePaymentStatus` (IN `p_paymentID` VARCHAR(255), IN `p_paymentStatus` ENUM('Pending','Completed','Failed'))   BEGIN
    UPDATE payment
    SET paymentStatus = p_paymentStatus
    WHERE paymentID = p_paymentID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateVoucher` (IN `p_voucherID` VARCHAR(255), IN `p_voucherStatus` ENUM('Activated','Deactivated'))   BEGIN
    UPDATE voucher
    SET voucherStatus = p_voucherStatus
    WHERE voucherID = p_voucherID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customerCode` int(11) NOT NULL,
  `customerID` varchar(512) DEFAULT NULL,
  `username` varchar(512) DEFAULT NULL,
  `password` varchar(512) DEFAULT NULL,
  `fullName` varchar(512) DEFAULT NULL,
  `email` varchar(512) DEFAULT NULL,
  `phone` varchar(512) DEFAULT NULL,
  `birthday` varchar(512) DEFAULT NULL,
  `address` varchar(512) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customerCode`, `customerID`, `username`, `password`, `fullName`, `email`, `phone`, `birthday`, `address`) VALUES
(1, 'C1', 'Kimberly123', 'password123', 'Kimberly Bremer', 'kimberlybremer@gmail.com', '81189991234', '2001-11-24', 'Berlin'),
(2, 'C2', 'Sasha123', 'password123', 'Sasha Alicia', 'sashaalicia@gmail.com', '81231425667', '2000-09-20', 'Sydney'),
(3, 'C3', 'Zhang123', 'password123', 'Qiu Zhang', 'qiuzhang@gmail.com', '81287871232', '1999-02-10', 'Taiwan'),
(4, 'C4', 'Luffy', 'raoarrrr123', 'Luffysandara', 'Luffysandara@gmail.com', '081219921965', '2002-01-20', 'Green Sedayu Mall');

-- --------------------------------------------------------

--
-- Table structure for table `delivery`
--

CREATE TABLE `delivery` (
  `deliveryCode` int(11) NOT NULL,
  `deliveryID` varchar(512) DEFAULT NULL,
  `orderID` varchar(512) NOT NULL,
  `outletID` varchar(512) DEFAULT NULL,
  `deliveryType` varchar(512) DEFAULT NULL,
  `deliveryAddress` varchar(512) DEFAULT NULL,
  `deliveryFee` double DEFAULT NULL,
  `deliveryStatus` enum('Pending','Out for Delivery','Delivered') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `order`
--

CREATE TABLE `order` (
  `orderCode` int(11) NOT NULL,
  `orderID` varchar(512) DEFAULT NULL,
  `customerID` varchar(512) DEFAULT NULL,
  `voucherID` varchar(20) DEFAULT NULL,
  `paymentID` varchar(512) DEFAULT NULL,
  `orderDateTime` datetime DEFAULT NULL,
  `orderStatus` varchar(512) DEFAULT NULL,
  `orderTotalPrice` double NOT NULL DEFAULT 0,
  `orderTotalAfterDiscount` double NOT NULL DEFAULT 0,
  `discountPercentage` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `orderdetail`
--

CREATE TABLE `orderdetail` (
  `orderDetailCode` int(11) NOT NULL,
  `orderID` varchar(512) DEFAULT NULL,
  `productID` varchar(512) DEFAULT NULL,
  `quantityOrdered` varchar(512) DEFAULT NULL,
  `notes` varchar(512) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `orderdetail`
--
DELIMITER $$
CREATE TRIGGER `productStockTrigger` AFTER INSERT ON `orderdetail` FOR EACH ROW BEGIN
    DECLARE currentStockDiff INT;  -- Declare the variable here

    -- Calculate the difference between currentStock and quantityOrdered
    SELECT (p.dailyStock - NEW.quantityOrdered) INTO currentStockDiff
    FROM gothamtreats.product p
    WHERE p.productID = NEW.productID;

    -- Ensure the currentStockDiff is non-negative
    SET currentStockDiff = GREATEST(currentStockDiff, 0);

    -- Update the dailyStock in the gothamtreats.product table
    UPDATE gothamtreats.product p
    SET p.dailyStock = currentStockDiff
    WHERE p.productID = NEW.productID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orderflagtable`
--

CREATE TABLE `orderflagtable` (
  `id` int(11) NOT NULL,
  `orderID_created` varchar(5) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `orderflagtable`
--

INSERT INTO `orderflagtable` (`id`, `orderID_created`) VALUES
(1, 'O30');

--
-- Triggers `orderflagtable`
--
DELIMITER $$
CREATE TRIGGER `insertOrderDetailDimension` AFTER UPDATE ON `orderflagtable` FOR EACH ROW BEGIN
    INSERT INTO gothamdwh.orderDetail_dimension (
        orderID,
        productID,
        quantityOrdered,
        notes
    )
    SELECT
        o.orderID,
        o.productID,
        o.quantityOrdered,
        o.notes
    FROM
        gothamtreats.orderDetail o
    WHERE
        o.orderID = NEW.orderID_created;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insertOrderDimension` AFTER UPDATE ON `orderflagtable` FOR EACH ROW BEGIN
    INSERT INTO gothamdwh.order_dimension (
        orderID,
        customerID,
        voucherID,
        paymentID,
        orderDateTime,
        orderStatus,
        orderTotalPrice,
        orderTotalAfterDiscount
    )
    SELECT
        o.orderID,
        o.customerID,
        o.voucherID,
        o.paymentID,
        o.orderDateTime,
        o.orderStatus,
        o.orderTotalPrice,
        o.orderTotalAfterDiscount
    FROM
        gothamtreats.order o
    WHERE
        o.orderID = NEW.orderID_created;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `outlet`
--

CREATE TABLE `outlet` (
  `outletCode` int(11) NOT NULL,
  `outletID` varchar(512) DEFAULT NULL,
  `outletLocation` varchar(512) DEFAULT NULL,
  `outletAddress` varchar(512) DEFAULT NULL,
  `outletPostalCode` int(11) DEFAULT NULL,
  `outletPhoneNumber` int(11) DEFAULT NULL,
  `outletOpeningHour` varchar(512) DEFAULT NULL,
  `outletClosingHour` varchar(512) DEFAULT NULL,
  `outletStartingDay` varchar(512) DEFAULT NULL,
  `outletClosingDay` varchar(512) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `outlet`
--

INSERT INTO `outlet` (`outletCode`, `outletID`, `outletLocation`, `outletAddress`, `outletPostalCode`, `outletPhoneNumber`, `outletOpeningHour`, `outletClosingHour`, `outletStartingDay`, `outletClosingDay`) VALUES
(1, 'OL1', 'Pakubuwono', 'Jl. Bumi No. 4, Blok M, Kebayoran Baru, Jakarta Selatan', 12160, 2147483647, '9:00 AM', '5:00 PM', 'Monday', 'Sunday'),
(2, 'OL2', 'PIK', 'Batavia PIK, Daerah Khusus Ibukota Jakarta', 14470, 2147483647, '9:00 AM', '5:00 PM', 'Monday', 'Sunday');

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `paymentCode` int(11) NOT NULL,
  `paymentID` varchar(512) DEFAULT NULL,
  `paymentAmount` varchar(512) DEFAULT NULL,
  `paymentDate` date DEFAULT NULL,
  `paymentType` varchar(512) DEFAULT NULL,
  `paymentStatus` enum('Pending','Completed','Failed','') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `productCode` int(11) NOT NULL,
  `productID` varchar(512) DEFAULT NULL,
  `productName` varchar(512) DEFAULT NULL,
  `productPrice` int(11) DEFAULT NULL,
  `dailyStock` int(11) DEFAULT NULL,
  `productCategory` enum('Cookie','DessertBox','Pudding','Coffee','Milk','Pie') DEFAULT NULL,
  `productDescription` text NOT NULL,
  `productImage` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`productCode`, `productID`, `productName`, `productPrice`, `dailyStock`, `productCategory`, `productDescription`, `productImage`) VALUES
(1, 'P1', 'The Nolita', 65000, 0, 'Cookie', 'Indulge in the exquisite taste of The Nolita cookie, a delightful treat that combines a perfect blend of flavors. With a rich texture and a heavenly aroma, this cookie is a true delight for your taste buds. Whether you\'re a cookie enthusiast or just looking for a sweet escape, The Nolita is a must-try.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/9f2edb23-6bb6-4130-b5ad-4cddd3dc418e_Go-Biz_20210615_111149.jpeg?auto=format'),
(2, 'P2', 'The Chelsea', 52000, 0, 'Cookie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/14c8dd34-3620-47a8-9d09-d26278eed044_Go-Biz_20210615_110031.jpeg?auto=format'),
(3, 'P3', 'The Upper East Side', 60000, 5, 'Cookie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/dd7723f6-2d25-4503-9936-46f5df2563c6_Go-Biz_20210615_111348.jpeg?auto=format'),
(4, 'P4', 'The Hells Kitchen', 52000, 7, 'Cookie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/0a22eb2a-36be-4788-9f37-062f018d2c72_Go-Biz_20210615_111103.jpeg?auto=format'),
(5, 'P5', 'The Greenwich Village', 46000, 8, 'Cookie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/915764bc-9945-4aa0-8754-15a6b5867185_Go-Biz_20210615_111503.jpeg?auto=format'),
(6, 'P6', 'The Soho', 46000, 10, 'Cookie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/07a8c3c8-c182-4139-87c8-f90f243affc4_Go-Biz_20210615_111426.jpeg?auto=format'),
(7, 'P7', 'The East Village', 48000, 10, 'Cookie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/9fbd5df3-e6c4-4b09-8830-6edd93aa2bcf_menu-item-image_1643168865336.jpg?auto=format'),
(8, 'P8', 'The Flat Iron', 33000, 10, 'Cookie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/84582121-61d0-4a4d-a4ce-765d0bfecfcd_Go-Biz_20231114_165111.jpeg?auto=format'),
(9, 'P9', 'The Calico', 48000, 10, 'Cookie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/9c0f7f5b-d2f9-4d9a-98a6-16c5a18388e3_Go-Biz_20230309_181025.jpeg?auto=format'),
(10, 'P10', 'The Little Italy - Tiramisu Dessert Box', 60000, 5, 'DessertBox', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/f97b674a-7140-4505-8553-8c3b49c551d7_Go-Biz_20220823_085908.jpeg?auto=format'),
(11, 'P11', 'The Broadway - Banana Pudding - Small', 35000, 15, 'Pudding', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/a1933c71-6edf-4e16-b7d6-bd5f86300dae_Go-Biz_20221115_151904.jpeg?auto=format'),
(12, 'P12', 'The Staten Island Pudding - Confetti Cake - Small', 40000, 12, 'Pudding', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/3ae4c175-2af9-4289-9cbe-55be64308e85_Go-Biz_20221115_151622.jpeg?auto=format'),
(13, 'P13', 'The Dumbo Cereal Milk', 48000, 20, 'Milk', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/342bab52-897f-49f8-8dcc-1ff09f8beca5_Go-Biz_20210615_111741.jpeg?auto=format'),
(14, 'P14', 'The Bronx Coffee Cereal Milk', 54000, 20, 'Milk', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/df78aed5-94cd-42e8-85a9-1fe97cafcc28_Go-Biz_20210715_090328.jpeg?auto=format'),
(15, 'P15', 'The Central Park Regal Cereal Milk', 48000, 20, 'Milk', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/92bea5b1-96a0-46c1-a368-f431995e2add_Go-Biz_20210715_090501.jpeg?auto=format'),
(16, 'P16', 'The Brooklyn Pie - Original', 48000, 10, 'Pie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/e8b19867-26fe-4145-95d4-2fde3c7df46c_Go-Biz_20220519_200213.jpeg?auto=format'),
(17, 'P17', 'The Brooklyn Pie Chocolate Rum', 48000, 10, 'Pie', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras consequat ullamcorper orci, eget posuere turpis pellentesque eu. Fusce dignissim justo eu eros efficitur volutpat. Etiam commodo libero mauris, nec egestas risus lobortis eu. Morbi consectetur mauris mi, eu vulputate urna varius at.', 'https://i.gojekapi.com/darkroom/gofood-indonesia/v2/images/uploads/dae1d7bf-03d1-42ed-976e-edbb2e3dd013_Go-Biz_20210616_091610.jpeg?auto=format');

-- --------------------------------------------------------

--
-- Table structure for table `voucher`
--

CREATE TABLE `voucher` (
  `voucherIDCode` int(11) NOT NULL,
  `voucherID` varchar(512) DEFAULT NULL,
  `voucherCode` varchar(512) DEFAULT NULL,
  `discountPercentage` int(11) DEFAULT NULL,
  `voucherRequirements` int(11) DEFAULT NULL,
  `voucherStatus` enum('Activated','Deactivated') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `voucher`
--

INSERT INTO `voucher` (`voucherIDCode`, `voucherID`, `voucherCode`, `discountPercentage`, `voucherRequirements`, `voucherStatus`) VALUES
(1, 'V1', 'TREATS20', 20, 100000, 'Deactivated'),
(2, 'V2', 'COOKIE15', 15, 30000, 'Activated'),
(3, 'V3', 'GOATED', 10, 10000, 'Activated');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customerCode`);

--
-- Indexes for table `delivery`
--
ALTER TABLE `delivery`
  ADD PRIMARY KEY (`deliveryCode`);

--
-- Indexes for table `order`
--
ALTER TABLE `order`
  ADD PRIMARY KEY (`orderCode`);

--
-- Indexes for table `orderdetail`
--
ALTER TABLE `orderdetail`
  ADD PRIMARY KEY (`orderDetailCode`);

--
-- Indexes for table `orderflagtable`
--
ALTER TABLE `orderflagtable`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `outlet`
--
ALTER TABLE `outlet`
  ADD PRIMARY KEY (`outletCode`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`paymentCode`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`productCode`);

--
-- Indexes for table `voucher`
--
ALTER TABLE `voucher`
  ADD PRIMARY KEY (`voucherIDCode`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customerCode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `delivery`
--
ALTER TABLE `delivery`
  MODIFY `deliveryCode` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order`
--
ALTER TABLE `order`
  MODIFY `orderCode` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orderdetail`
--
ALTER TABLE `orderdetail`
  MODIFY `orderDetailCode` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orderflagtable`
--
ALTER TABLE `orderflagtable`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `outlet`
--
ALTER TABLE `outlet`
  MODIFY `outletCode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `paymentCode` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `productCode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `voucher`
--
ALTER TABLE `voucher`
  MODIFY `voucherIDCode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `activateVoucher` ON SCHEDULE EVERY 1 DAY STARTS '2023-12-15 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    DECLARE currentDayOfWeek INT;

    -- Get the current day of the week (Sunday = 1, Monday = 2, ..., Saturday = 7)
    SET currentDayOfWeek = DAYOFWEEK(CURDATE());

    -- Call the stored procedure updateVoucher based on the day of the week
    CALL updateVoucher('V1', CASE WHEN currentDayOfWeek BETWEEN 2 AND 6 THEN 'Activated' ELSE 'Deactivated' END);
    CALL updateVoucher('V2', CASE WHEN currentDayOfWeek BETWEEN 2 AND 6 THEN 'Activated' ELSE 'Deactivated' END);
    CALL updateVoucher('V3', CASE WHEN currentDayOfWeek BETWEEN 2 AND 6 THEN 'Deactivated' ELSE 'Activated' END);
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

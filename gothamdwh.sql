-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 14, 2024 at 05:33 PM
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
-- Database: `gothamdwh`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `createTimeDimension` (IN `startdate` DATE, IN `stopdate` DATE)   BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;

    -- Ensure that the auto-increment counter is set appropriately
    -- Replace 'id' with the actual name of your primary key column
    SET @max_id = (SELECT COALESCE(MAX(id), 0) + 1 FROM time_dimension);
    SET @sql = CONCAT('ALTER TABLE time_dimension AUTO_INCREMENT = ', @max_id);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    WHILE currentdate <= stopdate DO
        INSERT INTO time_dimension (db_date, year, month, day, day_name, month_name)
        VALUES (
            currentdate,
            YEAR(currentdate),
            MONTH(currentdate),
            DAY(currentdate),
            DATE_FORMAT(currentdate, '%W'),
            DATE_FORMAT(currentdate, '%M')
        );

        SET currentdate = ADDDATE(currentdate, INTERVAL 1 DAY);
    END WHILE;
    
    -- Reset the auto-increment counter to the maximum existing value
    SET @sql_reset = 'ALTER TABLE time_dimension AUTO_INCREMENT = 1';
    PREPARE stmt_reset FROM @sql_reset;
    EXECUTE stmt_reset;
    DEALLOCATE PREPARE stmt_reset;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `fact_table_1`
--

CREATE TABLE `fact_table_1` (
  `timeID` varchar(15) NOT NULL,
  `orderID` varchar(15) NOT NULL,
  `productID` varchar(15) NOT NULL,
  `quantityOrdered` int(11) NOT NULL,
  `totalQuantityPerDay` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `fact_table_2`
--

CREATE TABLE `fact_table_2` (
  `timeID` varchar(15) NOT NULL,
  `productID` varchar(15) NOT NULL,
  `orderID` varchar(15) NOT NULL,
  `orderQuantity` varchar(15) NOT NULL,
  `currentStock` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `fact_table_3`
--

CREATE TABLE `fact_table_3` (
  `timeID` varchar(15) NOT NULL,
  `voucherID` varchar(15) NOT NULL,
  `orderID` varchar(15) NOT NULL,
  `totalBeforeDiscount` double NOT NULL,
  `discountPercentage` double NOT NULL,
  `totalAfterDiscount` double NOT NULL,
  `totalCostAfterDelivery` double NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `orderdetail_dimension`
--

CREATE TABLE `orderdetail_dimension` (
  `orderDetailCode` int(11) NOT NULL,
  `orderID` varchar(512) DEFAULT NULL,
  `productID` varchar(512) DEFAULT NULL,
  `quantityOrdered` varchar(512) DEFAULT NULL,
  `notes` varchar(512) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `orderdetail_dimension`
--
DELIMITER $$
CREATE TRIGGER `insertIntoFactTable1` AFTER INSERT ON `orderdetail_dimension` FOR EACH ROW BEGIN
    DECLARE newTimeID INT;
    DECLARE currentTotalQuantityPerDay INT;
    DECLARE insertedTQPD INT;

    -- Select the latest id for the current date from time_dimension
    SELECT id INTO newTimeID
    FROM gothamdwh.time_dimension
    ORDER BY id DESC
    LIMIT 1;
    
        -- Calculate the totalQuantityPerDay for the product before inserting the new row
    SET currentTotalQuantityPerDay = (
        SELECT COALESCE(SUM(quantityOrdered), 0)
        FROM fact_table_1
        WHERE timeID = newTimeID AND productID = NEW.productID
    );
    
    SET insertedTQPD  = currentTotalQuantityPerDay + NEW.quantityOrdered;

    -- Update totalQuantityPerDay if the row exists, otherwise insert a new row
    IF currentTotalQuantityPerDay IS NOT NULL THEN
        INSERT INTO fact_table_1 (timeID, orderID, productID, quantityOrdered, totalQuantityPerDay)
        VALUES (newTimeID, NEW.orderID, NEW.productID, NEW.quantityOrdered, insertedTQPD);
    ELSE
        INSERT INTO fact_table_1 (timeID, orderID, productID, quantityOrdered, totalQuantityPerDay)
        VALUES (newTimeID, NEW.orderID, NEW.productID, NEW.quantityOrdered, NEW.quantityOrdered);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insertIntoFactTable2` AFTER INSERT ON `orderdetail_dimension` FOR EACH ROW BEGIN
    DECLARE newTimeID VARCHAR(15);
    DECLARE currentStockDiff INT;

    -- Assuming that timeID is generated automatically
    SELECT id INTO newTimeID FROM gothamdwh.time_dimension WHERE db_date = CURDATE();

    -- Calculate the difference between currentStock and quantityOrdered
    SELECT GREATEST((p.dailyStock - NEW.quantityOrdered), 0) INTO currentStockDiff
    FROM product_dimension p
    WHERE p.productID = NEW.productID;

    -- Ensure the currentStockDiff is non-negative
    SET currentStockDiff = GREATEST(currentStockDiff, 0);

    -- Insert or update the fact_table_2
    INSERT INTO gothamdwh.fact_table_2 (timeID, productID, orderID, orderQuantity, currentStock)
    VALUES (newTimeID, NEW.productID, NEW.orderID, NEW.quantityOrdered, currentStockDiff)
    ON DUPLICATE KEY UPDATE
    orderQuantity = orderQuantity + NEW.quantityOrdered,
    currentStock = currentStockDiff;

    -- Update the dailyStock in the product_dimension table
    UPDATE product_dimension p
    SET p.dailyStock = currentStockDiff
    WHERE p.productID = NEW.productID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_dimension`
--

CREATE TABLE `order_dimension` (
  `orderCode` int(11) NOT NULL,
  `orderID` varchar(512) DEFAULT NULL,
  `customerID` varchar(512) DEFAULT NULL,
  `voucherID` varchar(512) DEFAULT NULL,
  `paymentID` varchar(512) DEFAULT NULL,
  `orderDateTime` datetime DEFAULT NULL,
  `orderStatus` varchar(512) DEFAULT NULL,
  `orderTotalPrice` double DEFAULT NULL,
  `orderTotalAfterDiscount` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `order_dimension`
--
DELIMITER $$
CREATE TRIGGER `insertIntoFactTable3` AFTER INSERT ON `order_dimension` FOR EACH ROW BEGIN
    -- Declare variables to store the necessary information
    DECLARE v_timeID VARCHAR(15);
    DECLARE v_voucherID VARCHAR(20);
    DECLARE v_orderID VARCHAR(20);
    DECLARE v_orderTotalPrice DOUBLE;
    DECLARE v_discountPercentage DOUBLE;
    DECLARE v_totalAfterDiscount DOUBLE;
    DECLARE v_totalCostAfterDelivery DOUBLE;

    -- Retrieve the latest timeID for the current date from the time_dimension table
    SELECT id INTO v_timeID
    FROM gothamdwh.time_dimension
    WHERE db_date = CURDATE()
    ORDER BY id DESC
    LIMIT 1;

    -- Retrieve necessary information based on the newly inserted row
    SELECT
        voucherID,
        orderID,
        orderTotalPrice,
        orderTotalAfterDiscount,
        orderTotalAfterDiscount + 25000
    INTO
        v_voucherID,
        v_orderID,
        v_orderTotalPrice,
        v_totalAfterDiscount,
        v_totalCostAfterDelivery
    FROM
        gothamdwh.order_dimension
    WHERE
        orderID = NEW.orderID;

    -- Retrieve discountPercentage based on the matching voucherID
    SELECT discountPercentage INTO v_discountPercentage
    FROM gothamdwh.voucher_dimension
    WHERE voucherID = v_voucherID;

    -- Insert the retrieved information into gothamdwh.fact_table_3
    INSERT INTO gothamdwh.fact_table_3 (
        timeID,
        voucherID,
        orderID,
        totalBeforeDiscount,
        discountPercentage,
        totalAfterDiscount,
        totalCostAfterDelivery
    )
    VALUES (
        v_timeID,
        v_voucherID,
        v_orderID,
        v_orderTotalPrice,
        v_discountPercentage,
        v_totalAfterDiscount,
        v_totalCostAfterDelivery
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `product_dimension`
--

CREATE TABLE `product_dimension` (
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
-- Dumping data for table `product_dimension`
--

INSERT INTO `product_dimension` (`productCode`, `productID`, `productName`, `productPrice`, `dailyStock`, `productCategory`, `productDescription`, `productImage`) VALUES
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
-- Table structure for table `time_dimension`
--

CREATE TABLE `time_dimension` (
  `id` int(11) NOT NULL,
  `db_date` date DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `day` int(11) DEFAULT NULL,
  `day_name` varchar(20) DEFAULT NULL,
  `month_name` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `time_dimension`
--

INSERT INTO `time_dimension` (`id`, `db_date`, `year`, `month`, `day`, `day_name`, `month_name`) VALUES
(20231215, '2023-12-15', 2023, 12, 15, 'Friday', 'December'),
(20231216, '2023-12-16', 2023, 12, 16, 'Saturday', 'December'),
(20231217, '2023-12-17', 2023, 12, 17, 'Sunday', 'December'),
(20231218, '2023-12-18', 2023, 12, 18, 'Monday', 'December'),
(20231219, '2023-12-19', 2023, 12, 19, 'Tuesday', 'December'),
(20231220, '2023-12-20', 2023, 12, 20, 'Wednesday', 'December'),
(20231221, '2023-12-21', 2023, 12, 21, 'Thursday', 'December'),
(20231222, '2023-12-22', 2023, 12, 22, 'Friday', 'December'),
(20231223, '2023-12-23', 2023, 12, 23, 'Saturday', 'December'),
(20231224, '2023-12-24', 2023, 12, 24, 'Sunday', 'December'),
(20231225, '2023-12-25', 2023, 12, 25, 'Monday', 'December'),
(20231226, '2023-12-26', 2023, 12, 26, 'Tuesday', 'December'),
(20231227, '2023-12-27', 2023, 12, 27, 'Wednesday', 'December'),
(20231228, '2023-12-28', 2023, 12, 28, 'Thursday', 'December'),
(20231229, '2023-12-29', 2023, 12, 29, 'Friday', 'December'),
(20231230, '2023-12-30', 2023, 12, 30, 'Saturday', 'December'),
(20231231, '2023-12-31', 2023, 12, 31, 'Sunday', 'December'),
(20240101, '2024-01-01', 2024, 1, 1, 'Monday', 'January'),
(20240102, '2024-01-02', 2024, 1, 2, 'Tuesday', 'January'),
(20240103, '2024-01-03', 2024, 1, 3, 'Wednesday', 'January'),
(20240104, '2024-01-04', 2024, 1, 4, 'Thursday', 'January'),
(20240105, '2024-01-05', 2024, 1, 5, 'Friday', 'January'),
(20240106, '2024-01-06', 2024, 1, 6, 'Saturday', 'January'),
(20240107, '2024-01-07', 2024, 1, 7, 'Sunday', 'January'),
(20240108, '2024-01-08', 2024, 1, 8, 'Monday', 'January'),
(20240109, '2024-01-09', 2024, 1, 9, 'Tuesday', 'January'),
(20240110, '2024-01-10', 2024, 1, 10, 'Wednesday', 'January'),
(20240111, '2024-01-11', 2024, 1, 11, 'Thursday', 'January'),
(20240112, '2024-01-12', 2024, 1, 12, 'Friday', 'January'),
(20240113, '2024-01-13', 2024, 1, 13, 'Saturday', 'January'),
(20240114, '2024-01-14', 2024, 1, 14, 'Sunday', 'January'),
(20240115, '2024-01-15', 2024, 1, 15, 'Monday', 'January'),
(20240116, '2024-01-16', 2024, 1, 16, 'Tuesday', 'January'),
(20240117, '2024-01-17', 2024, 1, 17, 'Wednesday', 'January'),
(20240118, '2024-01-18', 2024, 1, 18, 'Thursday', 'January'),
(20240119, '2024-01-19', 2024, 1, 19, 'Friday', 'January'),
(20240120, '2024-01-20', 2024, 1, 20, 'Saturday', 'January'),
(20240121, '2024-01-21', 2024, 1, 21, 'Sunday', 'January'),
(20240122, '2024-01-22', 2024, 1, 22, 'Monday', 'January'),
(20240123, '2024-01-23', 2024, 1, 23, 'Tuesday', 'January'),
(20240124, '2024-01-24', 2024, 1, 24, 'Wednesday', 'January'),
(20240125, '2024-01-25', 2024, 1, 25, 'Thursday', 'January'),
(20240126, '2024-01-26', 2024, 1, 26, 'Friday', 'January'),
(20240127, '2024-01-27', 2024, 1, 27, 'Saturday', 'January'),
(20240128, '2024-01-28', 2024, 1, 28, 'Sunday', 'January'),
(20240129, '2024-01-29', 2024, 1, 29, 'Monday', 'January'),
(20240130, '2024-01-30', 2024, 1, 30, 'Tuesday', 'January'),
(20240131, '2024-01-31', 2024, 1, 31, 'Wednesday', 'January'),
(20240201, '2024-02-01', 2024, 2, 1, 'Thursday', 'February'),
(20240202, '2024-02-02', 2024, 2, 2, 'Friday', 'February'),
(20240203, '2024-02-03', 2024, 2, 3, 'Saturday', 'February'),
(20240204, '2024-02-04', 2024, 2, 4, 'Sunday', 'February'),
(20240205, '2024-02-05', 2024, 2, 5, 'Monday', 'February'),
(20240206, '2024-02-06', 2024, 2, 6, 'Tuesday', 'February'),
(20240207, '2024-02-07', 2024, 2, 7, 'Wednesday', 'February'),
(20240208, '2024-02-08', 2024, 2, 8, 'Thursday', 'February'),
(20240209, '2024-02-09', 2024, 2, 9, 'Friday', 'February'),
(20240210, '2024-02-10', 2024, 2, 10, 'Saturday', 'February'),
(20240211, '2024-02-11', 2024, 2, 11, 'Sunday', 'February'),
(20240212, '2024-02-12', 2024, 2, 12, 'Monday', 'February'),
(20240213, '2024-02-13', 2024, 2, 13, 'Tuesday', 'February'),
(20240214, '2024-02-14', 2024, 2, 14, 'Wednesday', 'February'),
(20240215, '2024-02-15', 2024, 2, 15, 'Thursday', 'February');

-- --------------------------------------------------------

--
-- Table structure for table `voucher_dimension`
--

CREATE TABLE `voucher_dimension` (
  `voucherIDCode` int(11) NOT NULL,
  `voucherID` varchar(512) DEFAULT NULL,
  `voucherCode` varchar(512) DEFAULT NULL,
  `discountPercentage` int(255) DEFAULT NULL,
  `voucherRequirements` varchar(512) DEFAULT NULL,
  `voucherStatus` enum('Activated','Deactivated') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `voucher_dimension`
--

INSERT INTO `voucher_dimension` (`voucherIDCode`, `voucherID`, `voucherCode`, `discountPercentage`, `voucherRequirements`, `voucherStatus`) VALUES
(1, 'V1', 'TREATS20', 20, '100000', 'Deactivated'),
(2, 'V2', 'COOKIE15', 15, '30000', 'Activated'),
(3, 'V3', 'GOATED', 10, '10000', 'Activated');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `fact_table_1`
--
ALTER TABLE `fact_table_1`
  ADD PRIMARY KEY (`timeID`,`orderID`,`productID`),
  ADD KEY `outletID` (`orderID`),
  ADD KEY `deliveryID` (`productID`);

--
-- Indexes for table `fact_table_2`
--
ALTER TABLE `fact_table_2`
  ADD PRIMARY KEY (`timeID`,`productID`,`orderID`),
  ADD KEY `productID` (`productID`),
  ADD KEY `orderID` (`orderID`);

--
-- Indexes for table `fact_table_3`
--
ALTER TABLE `fact_table_3`
  ADD PRIMARY KEY (`timeID`,`voucherID`,`orderID`),
  ADD KEY `voucherID` (`voucherID`),
  ADD KEY `orderID` (`orderID`);

--
-- Indexes for table `orderdetail_dimension`
--
ALTER TABLE `orderdetail_dimension`
  ADD PRIMARY KEY (`orderDetailCode`);

--
-- Indexes for table `order_dimension`
--
ALTER TABLE `order_dimension`
  ADD PRIMARY KEY (`orderCode`);

--
-- Indexes for table `product_dimension`
--
ALTER TABLE `product_dimension`
  ADD PRIMARY KEY (`productCode`);

--
-- Indexes for table `time_dimension`
--
ALTER TABLE `time_dimension`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `voucher_dimension`
--
ALTER TABLE `voucher_dimension`
  ADD PRIMARY KEY (`voucherIDCode`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `orderdetail_dimension`
--
ALTER TABLE `orderdetail_dimension`
  MODIFY `orderDetailCode` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_dimension`
--
ALTER TABLE `order_dimension`
  MODIFY `orderCode` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_dimension`
--
ALTER TABLE `product_dimension`
  MODIFY `productCode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `time_dimension`
--
ALTER TABLE `time_dimension`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20240217;

--
-- AUTO_INCREMENT for table `voucher_dimension`
--
ALTER TABLE `voucher_dimension`
  MODIFY `voucherIDCode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

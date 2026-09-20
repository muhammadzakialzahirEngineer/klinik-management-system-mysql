-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 20, 2026 at 04:36 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sbd_sistembisnis_a112416056`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_buat_resep` (IN `p_id_resep` VARCHAR(10), IN `p_id_kunjungan` VARCHAR(10), IN `p_id_poli` VARCHAR(10), IN `p_keterangan` TEXT, IN `p_id_obat` VARCHAR(10), IN `p_jumlah` INT)   BEGIN
    DECLARE v_stok INT DEFAULT 0;
    SELECT stock INTO v_stok FROM obat WHERE id_obat = p_id_obat;
    IF v_stok < p_jumlah THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok obat tidak mencukupi.';
    ELSE
        INSERT IGNORE INTO resep (id_resep, id_kunjungan, id_poli, keterangan)
        VALUES (p_id_resep, p_id_kunjungan, p_id_poli, p_keterangan);
        INSERT INTO detail_resep (id_resep, id_obat, jumlah)
        VALUES (p_id_resep, p_id_obat, p_jumlah);
        UPDATE obat SET stock = stock - p_jumlah WHERE id_obat = p_id_obat;
        SELECT 'Resep berhasil dibuat dan stok diperbarui.' AS pesan;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_daftar_kunjungan` (IN `p_id_kunjungan` VARCHAR(10), IN `p_id_pasien` VARCHAR(10), IN `p_id_dokter` VARCHAR(10), IN `p_id_poli` VARCHAR(10), IN `p_tanggal` DATE, IN `p_keluhan` TEXT)   BEGIN
    DECLARE v_exist INT DEFAULT 0;
    SELECT COUNT(*) INTO v_exist FROM pasien WHERE id_pasien = p_id_pasien;
    IF v_exist = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pasien tidak ditemukan.';
    ELSE
        INSERT INTO kunjungan (id_kunjungan, id_pasien, id_dokter, id_poli, tanggal_kunjungan, keluhan)
        VALUES (p_id_kunjungan, p_id_pasien, p_id_dokter, p_id_poli, p_tanggal, p_keluhan);
        SELECT 'Kunjungan berhasil didaftarkan.' AS pesan;
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_status_stok` (`p_id_obat` VARCHAR(10)) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_stok INT DEFAULT 0;
    DECLARE v_status VARCHAR(20);
    SELECT stock INTO v_stok FROM obat WHERE id_obat = p_id_obat;
    IF v_stok = 0 THEN
        SET v_status = 'HABIS';
    ELSEIF v_stok <= 10 THEN
        SET v_status = 'HAMPIR HABIS';
    ELSE
        SET v_status = 'TERSEDIA';
    END IF;
    RETURN v_status;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_biaya_resep` (`p_id_resep` VARCHAR(10)) RETURNS DECIMAL(15,2) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_total DECIMAL(15,2) DEFAULT 0;
    SELECT SUM(o.harga * dr.jumlah) INTO v_total
    FROM detail_resep dr
    JOIN obat o ON dr.id_obat = o.id_obat
    WHERE dr.id_resep = p_id_resep;
    RETURN IFNULL(v_total, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_total_kunjungan` (`p_id_pasien` VARCHAR(10)) RETURNS INT(11) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_total INT DEFAULT 0;
    SELECT COUNT(*) INTO v_total FROM kunjungan WHERE id_pasien = p_id_pasien;
    RETURN v_total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `detail_resep`
--

CREATE TABLE `detail_resep` (
  `id_resep` varchar(10) NOT NULL,
  `id_obat` varchar(10) NOT NULL,
  `jumlah` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_resep`
--

INSERT INTO `detail_resep` (`id_resep`, `id_obat`, `jumlah`) VALUES
('RES001', 'OBT01', 10),
('RES001', 'OBT02', 6),
('RES002', 'OBT01', 6),
('RES003', 'OBT03', 1),
('RES004', 'OBT01', 5);

-- --------------------------------------------------------

--
-- Table structure for table `dokter`
--

CREATE TABLE `dokter` (
  `id_dokter` varchar(10) NOT NULL,
  `no_hp_dokter` varchar(15) DEFAULT NULL,
  `nama_dokter` varchar(100) NOT NULL,
  `spesialis` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dokter`
--

INSERT INTO `dokter` (`id_dokter`, `no_hp_dokter`, `nama_dokter`, `spesialis`) VALUES
('D001', '081111111111', 'dr. Ahmad Fauzi', 'Umum'),
('D002', '082222222222', 'dr. Dewi Rahayu', 'Sp.A'),
('D003', '083333333333', 'dr. Eko Prasetyo', 'Sp.PD');

-- --------------------------------------------------------

--
-- Table structure for table `kunjungan`
--

CREATE TABLE `kunjungan` (
  `id_kunjungan` varchar(10) NOT NULL,
  `id_pasien` varchar(10) NOT NULL,
  `id_dokter` varchar(10) NOT NULL,
  `id_poli` varchar(10) NOT NULL,
  `tanggal_kunjungan` date NOT NULL,
  `keluhan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kunjungan`
--

INSERT INTO `kunjungan` (`id_kunjungan`, `id_pasien`, `id_dokter`, `id_poli`, `tanggal_kunjungan`, `keluhan`) VALUES
('KNJ001', 'P001', 'D001', 'POL01', '2024-06-01', 'Demam dan batuk'),
('KNJ002', 'P002', 'D002', 'POL02', '2024-06-02', 'Anak rewel, panas tinggi'),
('KNJ003', 'P003', 'D003', 'POL03', '2024-06-03', 'Sakit perut dan mual'),
('KNJ004', 'P002', 'D001', 'POL01', '2024-06-10', 'Batuk pilek');

--
-- Triggers `kunjungan`
--
DELIMITER $$
CREATE TRIGGER `trg_after_insert_kunjungan` AFTER INSERT ON `kunjungan` FOR EACH ROW BEGIN
    INSERT INTO log_kunjungan (id_kunjungan, id_pasien, aksi, keterangan)
    VALUES (NEW.id_kunjungan, NEW.id_pasien, 'INSERT',
            CONCAT('Kunjungan baru ke poli ', NEW.id_poli, ' pada ', NEW.tanggal_kunjungan));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `log_kunjungan`
--

CREATE TABLE `log_kunjungan` (
  `id_log` int(11) NOT NULL,
  `id_kunjungan` varchar(10) DEFAULT NULL,
  `id_pasien` varchar(10) DEFAULT NULL,
  `aksi` varchar(50) DEFAULT NULL,
  `waktu` datetime DEFAULT current_timestamp(),
  `keterangan` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_kunjungan`
--

INSERT INTO `log_kunjungan` (`id_log`, `id_kunjungan`, `id_pasien`, `aksi`, `waktu`, `keterangan`) VALUES
(1, 'KNJ001', 'P001', 'INSERT', '2026-06-11 21:21:44', 'Kunjungan baru ke poli POL01 pada 2024-06-01'),
(2, 'KNJ002', 'P002', 'INSERT', '2026-06-11 21:21:44', 'Kunjungan baru ke poli POL02 pada 2024-06-02'),
(3, 'KNJ003', 'P003', 'INSERT', '2026-06-11 21:21:44', 'Kunjungan baru ke poli POL03 pada 2024-06-03'),
(4, 'KNJ004', 'P002', 'INSERT', '2026-06-11 21:58:54', 'Kunjungan baru ke poli POL01 pada 2024-06-10');

-- --------------------------------------------------------

--
-- Table structure for table `log_stok_obat`
--

CREATE TABLE `log_stok_obat` (
  `id_log` int(11) NOT NULL,
  `id_obat` varchar(10) DEFAULT NULL,
  `aksi` varchar(50) DEFAULT NULL,
  `stok_lama` int(11) DEFAULT NULL,
  `stok_baru` int(11) DEFAULT NULL,
  `waktu` datetime DEFAULT current_timestamp(),
  `keterangan` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_stok_obat`
--

INSERT INTO `log_stok_obat` (`id_log`, `id_obat`, `aksi`, `stok_lama`, `stok_baru`, `waktu`, `keterangan`) VALUES
(1, 'OBT01', 'UPDATE STOK', 100, 95, '2026-06-11 22:00:40', 'Perubahan stok obat: 100 -> 95'),
(2, 'OBT01', 'UPDATE STOK', 95, 84, '2026-06-11 22:04:56', 'Perubahan stok obat: 95 -> 84'),
(3, 'OBT02', 'UPDATE STOK', 8, 2, '2026-06-11 22:05:01', 'Perubahan stok obat: 8 -> 2'),
(4, 'OBT03', 'UPDATE STOK', 20, 19, '2026-06-11 22:05:07', 'Perubahan stok obat: 20 -> 19'),
(5, 'OBT02', 'UPDATE STOK', 2, 0, '2026-06-11 22:29:37', 'Perubahan stok obat: 2 -> 0'),
(6, 'OBT01', 'UPDATE STOK', 84, 90, '2026-06-11 22:30:29', 'Perubahan stok obat: 84 -> 90'),
(7, 'OBT03', 'UPDATE STOK', 19, 2, '2026-06-11 22:31:14', 'Perubahan stok obat: 19 -> 2'),
(8, 'OBT04', 'UPDATE STOK', 0, 30, '2026-06-11 22:31:21', 'Perubahan stok obat: 0 -> 30'),
(9, 'OBT02', 'UPDATE STOK', 0, 8, '2026-06-11 22:34:32', 'Perubahan stok obat: 0 -> 8');

-- --------------------------------------------------------

--
-- Table structure for table `obat`
--

CREATE TABLE `obat` (
  `id_obat` varchar(10) NOT NULL,
  `nama_obat` varchar(100) NOT NULL,
  `jenis` varchar(50) DEFAULT NULL,
  `harga` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stock` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `obat`
--

INSERT INTO `obat` (`id_obat`, `nama_obat`, `jenis`, `harga`, `stock`) VALUES
('OBT01', 'Paracetamol 500mg', 'Tablet', 2000.00, 90),
('OBT02', 'Amoxicillin 500mg', 'Kapsul', 3500.00, 8),
('OBT03', 'Antasida Syrup', 'Sirup', 15000.00, 2),
('OBT04', 'Vitamin C 1000mg', 'Tablet', 5000.00, 30);

--
-- Triggers `obat`
--
DELIMITER $$
CREATE TRIGGER `trg_after_update_stok_obat` AFTER UPDATE ON `obat` FOR EACH ROW BEGIN
    IF OLD.stock <> NEW.stock THEN
        INSERT INTO log_stok_obat (id_obat, aksi, stok_lama, stok_baru, keterangan)
        VALUES (NEW.id_obat, 'UPDATE STOK', OLD.stock, NEW.stock,
                CONCAT('Perubahan stok obat: ', OLD.stock, ' -> ', NEW.stock));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pasien`
--

CREATE TABLE `pasien` (
  `id_pasien` varchar(10) NOT NULL,
  `no_hp` varchar(15) NOT NULL,
  `nama_pasien` varchar(100) NOT NULL,
  `alamat` text DEFAULT NULL,
  `jenis_kelamin` enum('L','P') NOT NULL,
  `tanggal_lahir` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pasien`
--

INSERT INTO `pasien` (`id_pasien`, `no_hp`, `nama_pasien`, `alamat`, `jenis_kelamin`, `tanggal_lahir`) VALUES
('P001', '081234567890', 'Brahman Santoso', 'Jl. Mawar No.1, Jakarta', 'L', '1990-05-10'),
('P002', '082345678901', 'Siti Aminah', 'Jl. Melati No.5, Bandung', 'P', '1985-03-22'),
('P003', '083456789012', 'Rudi Hartono', 'Jl. Kenanga No.9, Surabaya', 'L', '2000-11-15');

-- --------------------------------------------------------

--
-- Table structure for table `poli`
--

CREATE TABLE `poli` (
  `id_poli` varchar(10) NOT NULL,
  `nama_poli` varchar(100) NOT NULL,
  `lokasi` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `poli`
--

INSERT INTO `poli` (`id_poli`, `nama_poli`, `lokasi`) VALUES
('POL01', 'Poli Umum', 'Lantai 1 Ruang 101'),
('POL02', 'Poli Anak', 'Lantai 1 Ruang 102'),
('POL03', 'Poli Dalam', 'Lantai 2 Ruang 201');

-- --------------------------------------------------------

--
-- Table structure for table `resep`
--

CREATE TABLE `resep` (
  `id_resep` varchar(10) NOT NULL,
  `id_kunjungan` varchar(10) NOT NULL,
  `id_poli` varchar(10) NOT NULL,
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resep`
--

INSERT INTO `resep` (`id_resep`, `id_kunjungan`, `id_poli`, `keterangan`) VALUES
('RES001', 'KNJ001', 'POL01', 'Diminum 3x sehari sesudah makan'),
('RES002', 'KNJ002', 'POL02', 'Diminum 2x sehari'),
('RES003', 'KNJ003', 'POL03', 'Diminum saat gejala muncul'),
('RES004', 'KNJ004', 'POL01', 'Minum 3x sehari');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `detail_resep`
--
ALTER TABLE `detail_resep`
  ADD PRIMARY KEY (`id_resep`,`id_obat`),
  ADD KEY `id_obat` (`id_obat`);

--
-- Indexes for table `dokter`
--
ALTER TABLE `dokter`
  ADD PRIMARY KEY (`id_dokter`);

--
-- Indexes for table `kunjungan`
--
ALTER TABLE `kunjungan`
  ADD PRIMARY KEY (`id_kunjungan`),
  ADD KEY `id_pasien` (`id_pasien`),
  ADD KEY `id_dokter` (`id_dokter`),
  ADD KEY `id_poli` (`id_poli`);

--
-- Indexes for table `log_kunjungan`
--
ALTER TABLE `log_kunjungan`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `log_stok_obat`
--
ALTER TABLE `log_stok_obat`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `obat`
--
ALTER TABLE `obat`
  ADD PRIMARY KEY (`id_obat`);

--
-- Indexes for table `pasien`
--
ALTER TABLE `pasien`
  ADD PRIMARY KEY (`id_pasien`);

--
-- Indexes for table `poli`
--
ALTER TABLE `poli`
  ADD PRIMARY KEY (`id_poli`);

--
-- Indexes for table `resep`
--
ALTER TABLE `resep`
  ADD PRIMARY KEY (`id_resep`),
  ADD KEY `id_kunjungan` (`id_kunjungan`),
  ADD KEY `id_poli` (`id_poli`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `log_kunjungan`
--
ALTER TABLE `log_kunjungan`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `log_stok_obat`
--
ALTER TABLE `log_stok_obat`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `detail_resep`
--
ALTER TABLE `detail_resep`
  ADD CONSTRAINT `detail_resep_ibfk_1` FOREIGN KEY (`id_resep`) REFERENCES `resep` (`id_resep`),
  ADD CONSTRAINT `detail_resep_ibfk_2` FOREIGN KEY (`id_obat`) REFERENCES `obat` (`id_obat`);

--
-- Constraints for table `kunjungan`
--
ALTER TABLE `kunjungan`
  ADD CONSTRAINT `kunjungan_ibfk_1` FOREIGN KEY (`id_pasien`) REFERENCES `pasien` (`id_pasien`),
  ADD CONSTRAINT `kunjungan_ibfk_2` FOREIGN KEY (`id_dokter`) REFERENCES `dokter` (`id_dokter`),
  ADD CONSTRAINT `kunjungan_ibfk_3` FOREIGN KEY (`id_poli`) REFERENCES `poli` (`id_poli`);

--
-- Constraints for table `resep`
--
ALTER TABLE `resep`
  ADD CONSTRAINT `resep_ibfk_1` FOREIGN KEY (`id_kunjungan`) REFERENCES `kunjungan` (`id_kunjungan`),
  ADD CONSTRAINT `resep_ibfk_2` FOREIGN KEY (`id_poli`) REFERENCES `poli` (`id_poli`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

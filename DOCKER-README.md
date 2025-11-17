# Memos with PostgreSQL

Deployment Memos sebagai Docker container dengan PostgreSQL sebagai database eksternal.

## Build

Untuk build Docker image lokal:

```bash
docker build -t memos-postgres .
```

Atau gunakan image resmi:
```bash
docker pull neosmemo/memos:latest
```

## Konfigurasi

Sebelum menjalankan, ubah konfigurasi di `docker-compose.yml`:

```yaml
environment:
  - MEMOS_DRIVER=postgres
  - MEMOS_DSN=postgresql://your_db_username:your_db_password@your_vps_ip:5432/memos_db_name?sslmode=disable
```

Ganti:
- `your_db_username`: username PostgreSQL Anda
- `your_db_password`: password PostgreSQL Anda
- `your_vps_ip`: IP address VPS Anda atau alamat host PostgreSQL
- `memos_db_name`: nama database PostgreSQL yang akan digunakan

## Menjalankan

1. Pastikan PostgreSQL server Anda sudah siap dan bisa diakses
2. Buat database jika belum ada: `CREATE DATABASE memos_db_name;`
3. Sesuaikan konfigurasi di `docker-compose.yml`
4. Jalankan perintah berikut:

```bash
docker-compose up -d
```

## Backup

Data akan disimpan di folder `./memos_data` secara persisten.

## Akses

Aplikasi akan tersedia di `http://localhost:5230` atau `http://[VPS_IP]:5230`

## Deploy ke VPS

1. Upload file-file berikut ke VPS Anda:
   - `docker-compose.yml`
   - (Opsional) `Dockerfile` jika Anda ingin build lokal

2. Pastikan PostgreSQL Anda bisa diakses dari jaringan eksternal

3. Jalankan aplikasi:
   ```bash
   docker-compose up -d
   ```

4. Gunakan reverse proxy seperti Nginx jika ingin mengakses dari internet
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Enums\JenisRequest;
use App\Services\AuditLogService;
use App\Services\GetTokenService;
use GuzzleHttp\Client;

class OutboundController
{
    // remote url
    private $remote_url;
    private $remote_fileds;
    private $remote_receive_status;
    private $remote_passkey;
    private $commitment_check_url;
    private $sso_url;
    private $header_key;
    private $header_value;

    // data izin
    private $nib;
    private $id_produk;
    private $id_proyek;
    private $oss_id;
    private $id_izin;
    private $kd_izin;
    private $kd_daerah;
    private $kewenangan;
    private $nomor_izin;
    private $tgl_terbit_izin;
    private $tgl_berlaku_izin;
    private $nama_ttd;
    private $nip_ttd;
    private $jabatan_ttd;
    private $status_izin;
    private $file_izin;
    private $keterangan;
    private $file_lampiran;
    private $nomenklatur_nomor_izin;
    private $bln_berlaku_izin;
    private $thn_berlaku_izin;
    private $kd_akun;
    private $kd_penerimaan;
    private $nominal;
                        
    public function __construct()
    {
        // remote url
        $this->remote_url = env('APP_URL') . '/api/receive-nib';
        $this->remote_fileds = env('APP_URL') . '/api/receive-file-izin';
        $this->remote_receive_status = env('APP_URL') . '/api/receive-status';
        $this->remote_passkey = "";
        $this->commitment_check_url = "";
        $this->sso_url = "";
        $this->header_key = "";
        $this->header_value = "";

        // data izin
        $this->nib = "1287000141282";
        $this->id_produk = "";
        $this->id_proyek = "R-202205191423292409792";
        $this->oss_id = "P-202101181402005969535";
        $this->id_izin = "I-202306201351596424899";
        $this->kd_izin = "059000000010";
        $this->kd_daerah = "";
        $this->kewenangan = "";
        $this->nomor_izin = "128700014128200050011";
        $this->tgl_terbit_izin = "2023-06-19";
        $this->tgl_berlaku_izin = "2023-06-19";
        $this->nama_ttd = "SOEHARTO";
        $this->nip_ttd = "-";
        $this->jabatan_ttd = "PRESIDEN";
        $this->status_izin = "51";
        $this->file_izin = "https://sertifikasi.postel.go.id/api_sertifikasi/files/tte/2865_138996_CRT.pdf";
        $this->keterangan = "Disetujui";
        $this->file_lampiran = "https://sertifikasi.postel.go.id/api_sertifikasi/files/tte/2865_138996_CRT.pdf";
        $this->nomenklatur_nomor_izin = "";
        $this->bln_berlaku_izin = "";
        $this->thn_berlaku_izin = "";
        $this->kd_akun = "";
        $this->kd_penerimaan = "";
        $this->nominal = "";

        $this->httpClient = new Client([
            'base_uri' => env('OSSHUB_ENDPOINT'),
        ]);

        $this->auditLogService = new AuditLogService();
        $this->getTokenService = new GetTokenService();
    }
    
    public function health(){
        try {
            $endpoint = $this->httpClient->getConfig('base_uri') . 'health';
            $response = $this->httpClient->get('health');
            $body = $response->getBody()->getContents();
            $this->auditLogService->log(
                'system',
                $endpoint,
                'GET',
                $response->getStatusCode(),
                JenisRequest::OUTBOUND->value,
                null,
                null,
                json_encode($response->getHeaders()),
                $body
            );
            return response($body, $response->getStatusCode())
                ->header('Content-Type', 'application/json');
        } catch (\Exception $e) {
            $this->auditLogService->log(
                'system',
                $this->httpClient->getConfig('base_uri') . 'health',
                'GET',
                '500',
                JenisRequest::OUTBOUND->value,
                null,
                null,
                null,
                $e->getMessage()
            );
            return response()->json([
                'error' => 'Unable to connect to health endpoint',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function login(){
        return $this->getTokenService->getToken();
    }

    public function set_remote_credential(){
        $accessToken = $this->getTokenService->getToken();
        $request = [
            "headers" => [
                "Authorization"  => "Bearer {$accessToken}",
                "Content-Type"  => "application/json"
            ],
            "json" => [
                "credential" => [
                    "remote_url" => $this->remote_url,
                    "remote_fileds" => $this->remote_fileds,
                    "remote_receive_status" => $this->remote_receive_status,
                    "remote_passkey" => $this->remote_passkey,
                    "commitment_check_url" => $this->commitment_check_url,
                    "sso_url" => $this->sso_url,
                    "custom_headers" => [
                        [
                            "key" => $this->header_key,
                            "value" => $this->header_value
                        ]
                    ]
                ]
            ]
        ];

        try {
            $response = $this->httpClient->request("POST", "yanlik/remote-credential", $request);
            $body = $response->getBody()->getContents();
            $this->auditLogService->log(
                'system',
                $this->httpClient->getConfig('base_uri') . 'yanlik/remote-credential',
                'POST',
                $response->getStatusCode(),
                JenisRequest::OUTBOUND->value,
                json_encode(array_merge($request["headers"], [
                    "Authorization" => "Bearer [HIDDEN]"
                ])),
                json_encode($request["json"]),
                json_encode($response->getHeaders()),
                $body
            );
            return response($body, $response->getStatusCode())
                ->header('Content-Type', 'application/json');    
        } catch (\Exception $e) {
            $this->auditLogService->log(
                'system',
                $this->httpClient->getConfig('base_uri') . 'yanlik/remote-credential',
                'POST',
                '500',
                JenisRequest::OUTBOUND->value,
                json_encode(array_merge($request["headers"], [
                    "Authorization" => "Bearer [HIDDEN]"
                ])),
                json_encode($request["json"]),
                null,
                $e->getMessage()
            );
            return response()->json([
                'error' => 'set remote credential failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function license_final(){
        $accessToken = $this->getTokenService->getToken();
        $request = [
            "headers" => [
                "Authorization"  => "Bearer {$accessToken}",
                "Content-Type"  => "application/json"
            ],
            "json" => [
                "IZINFINAL" => [
                    "nib" => $this->nib,
                    "id_produk" => $this->id_produk,
                    "id_proyek" => $this->id_proyek,
                    "oss_id" => $this->oss_id,
                    "id_izin" => $this->id_izin,
                    "kd_izin" => $this->kd_izin,
                    "kd_daerah" => $this->kd_daerah,
                    "kewenangan" => $this->kewenangan,
                    "nomor_izin" => $this->nomor_izin,
                    "tgl_terbit_izin" => $this->tgl_terbit_izin,
                    "tgl_berlaku_izin" => $this->tgl_berlaku_izin,
                    "nama_ttd" => $this->nama_ttd,
                    "nip_ttd" => $this->nip_ttd,
                    "jabatan_ttd" => $this->jabatan_ttd,
                    "status_izin" => $this->status_izin,
                    "file_izin" => $this->file_izin,
                    "keterangan" => $this->keterangan,
                    "file_lampiran" => $this->file_lampiran,
                    "nomenklatur_nomor_izin" => $this->nomenklatur_nomor_izin,
                    "bln_berlaku_izin" => $this->bln_berlaku_izin,
                    "thn_berlaku_izin" => $this->thn_berlaku_izin,
                    "data_pnbp" => [
                        "kd_akun" => $this->kd_akun,
                        "kd_penerimaan" => $this->kd_penerimaan,
                        "nominal" => $this->nominal
                    ]
                ]
            ]
        ];
        try {
            $response = $this->httpClient->request("POST", "license-final", $request);
            $body = $response->getBody()->getContents();
            $this->auditLogService->log(
                'system',
                $this->httpClient->getConfig('base_uri') . 'license-final',
                'POST',
                $response->getStatusCode(),
                JenisRequest::OUTBOUND->value,
                json_encode($request["headers"]),
                json_encode($request["json"]),
                json_encode($response->getHeaders()),
                $body,
            );
            return response($body, $response->getStatusCode())
                ->header('Content-Type', 'application/json');    
        } catch (\Exception $e) {
            $this->auditLogService->log(
                'system',
                $this->httpClient->getConfig('base_uri') . 'license-final',
                'POST',
                '500',
                JenisRequest::OUTBOUND->value,
                json_encode($request["headers"]),
                json_encode($request["json"]),
                null,
                $e->getMessage(),
            );
            return response()->json([
                'error' => 'license final failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function license_update(){
        $accessToken = $this->getTokenService->getToken();
        $request = [
            "headers" => [
                "Authorization"  => "Bearer {$accessToken}",
                "Content-Type"  => "application/json"
            ],
            "json" => [
                "IZINFINAL" => [
                    "nib" => $this->nib,
                    "id_proyek" => $this->id_proyek,
                    "oss_id" => $this->oss_id,
                    "id_izin" => $this->id_izin,
                    "kd_izin" => $this->kd_izin,
                    "kd_daerah" => $this->kd_daerah,
                    "kewenangan" => $this->kewenangan,
                    "nomor_izin" => $this->nomor_izin,
                    "tgl_terbit_izin" => $this->tgl_terbit_izin,
                    "tgl_berlaku_izin" => $this->tgl_berlaku_izin,
                    "nama_ttd" => $this->nama_ttd,
                    "nip_ttd" => $this->nip_ttd,
                    "jabatan_ttd" => $this->jabatan_ttd,
                    "status_izin" => $this->status_izin,
                    "file_izin" => $this->file_izin,
                    "keterangan" => $this->keterangan,
                    "file_lampiran" => $this->file_lampiran,
                    "nomenklatur_nomor_izin" => $this->nomenklatur_nomor_izin,
                    "bln_berlaku_izin" => $this->bln_berlaku_izin,
                    "thn_berlaku_izin" => $this->thn_berlaku_izin,
                "data_pnbp" => [
                        "kd_akun" => $this->kd_akun,
                        "kd_penerimaan" => $this->kd_penerimaan,
                        "nominal" => $this->nominal
                    ]
                ]
            ]
        ];
        try {
            $response = $this->httpClient->request("PUT", "license-update", $request);
            $body = $response->getBody()->getContents();
            $this->auditLogService->log(
                'system',
                $this->httpClient->getConfig('base_uri') . 'license-update',
                'PUT',
                $response->getStatusCode(),
                JenisRequest::OUTBOUND->value,
                json_encode(array_merge($request["headers"], [
                    "Authorization" => "Bearer [HIDDEN]"
                ])),
                json_encode($request["json"]),
                json_encode($response->getHeaders()),
                $body,
            );
            return response($body, $response->getStatusCode())
                ->header('Content-Type', 'application/json');    
        } catch (\Exception $e) {
            $this->auditLogService->log(
                'system',
                $this->httpClient->getConfig('base_uri') . 'license-update',
                'PUT',
                '500',
                JenisRequest::OUTBOUND->value,
                json_encode(array_merge($request["headers"], [
                    "Authorization" => "Bearer [HIDDEN]"
                ])),
                json_encode($request["json"]),
                null,
                $e->getMessage(),
            );
            return response()->json([
                'error' => 'license update failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}

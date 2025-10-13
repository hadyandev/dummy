<?php

namespace App\Enums;

enum JenisRequest: string
{
    case INBOUND = 'inbound';
    case OUTBOUND = 'outbound';

    public function label(): string
    {
        return match ($this) {
            self::INBOUND => 'Inbound',
            self::OUTBOUND => 'Outbound',
        };
    }

    public function getLabel(): string
    {
        return $this->label();
    }
}

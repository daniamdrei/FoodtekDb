<?php

namespace Database\Seeders;

use App\Models\DeliveryStatues;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DeliveryStatuesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DeliveryStatues::factory(20)->create();
    }
}

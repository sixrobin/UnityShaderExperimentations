Shader "EXO/EXO_Planet_Maps"
{
    Properties
    {
        [Header(LAND)]
        [Space(5)]
        _LandTex ("Land Map", 2D) = "white" {}
        _LandHeightTex ("Land Height Map", 2D) = "white" {}
        [Toggle] _InverseLandMap ("Inverse Land Map", float) = 0
        _LandColorA ("Land Color A", Color) = (0,1,0,1)
        _LandColorB ("Land Color B", Color) = (1,1,1,1)
        
        [Space(15)]
        
        [Header(WATER (BASE))]
        [Space(5)]
        _WaterCellsColor ("Cells Color", Color) = (1,1,1,1)
        _WaterVeinsColor ("Veins Color", Color) = (0,0,0,1)
        _AngleOffset ("Angle Offset", Range(0, 360)) = 0
        _CellDensity ("Cell Density", Range(1, 100)) = 1
        [IntRange] _WaterNoiseSharpness ("Sharpness", Range(1, 10)) = 1
        _AngleOffsetSpeed ("Angle Offset Speed", Range(0, 10)) = 0 
        
        [Header(WATER (SHORE WAVES))]
        [Space(5)]
        _ShoreWavesTex ("Shore Waves Map", 2D) = "white" {}
        _ShoreWavesSpeed ("Shore Waves Speed", Range(0, 10)) = 1
        _ShoreWavesColor ("Shore Waves Color", Color) = (1,1,1,1)
        
        [Header(WATER (FRESNEL))]
        [Space(5)]
        _WaterFresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _WaterFresnelWidth ("Fresnel Width", Range(0, 20)) = 1
        
        [Space(15)]
        
        [Header(BOUNDARIES)]
        [Space(5)]
        _BoundariesTex ("Boundaries Map", 2D) = "white" {}
        _BoundariesColor ("Boundaries Color", Color) = (0,0,0,1)
        
        [Space(15)]
        
        [Header(ROTATION)]
        [Space(5)]
        _RotationSpeed ("Rotation Speed", Range(0, 45)) = 1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _INVERSELANDMAP_ON

            #include "UnityCG.cginc"
            #define TAU 6.2831853071

            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 color : COLOR;
            };


            // Textures.
            sampler2D _LandTex;
            float4 _LandTex_ST;
            sampler2D _LandHeightTex;
            sampler2D _IceLandTex;
            sampler2D _ShoreWavesTex;
            sampler2D _BoundariesTex;

            // Land.
            float4 _LandColorA;
            float4 _LandColorB;
            
            // Water.
            float4 _WaterCellsColor;
            float4 _WaterVeinsColor;
            float _AngleOffset;
            float _AngleOffsetSpeed;
            float _CellDensity;
            float _WaterNoiseSharpness;
            
            // Shore waves.
            float4 _ShoreWavesColor;
            float4 _BoundariesColor;
            float _ShoreWavesSpeed;

            // Fresnel.
            float4 _WaterFresnelColor;
            float _WaterFresnelWidth;
            
            // Rotation.
            float _RotationSpeed;

            
            float get_wave(float2 uv, float waveSpeed)
            {
                float2 uv_centered = uv * 2 - 1;
                float radial_distance = length(uv_centered);
                float wave = cos((radial_distance - _Time.y * waveSpeed) * 5 * TAU);
                wave = wave * 0.5 + 0.5;
                return wave;
            }

            float get_wave(float coord, float waveSpeed)
            {
                float wave = cos((coord - _Time.y * waveSpeed) * 5 * TAU);
                wave = wave * 0.5 + 0.5;
                return wave;
            }

            inline float2 voronoi_noise_random_vector(float2 UV, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                UV = frac(sin(mul(UV, m)) * 46839.32);
                return float2(sin(UV.y * offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
            }

            void voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float3 res = float3(8.0, 0.0, 0.0);

                for (int y = -1; y <= 1; ++y)
                {
                    for (int x = -1; x <= 1; ++x)
                    {
                        float2 lattice = float2(x, y);
                        float2 offset = voronoi_noise_random_vector(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);
                        if (d < res.x)
                        {
                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;
                        }
                    }
                }
            }

            float3 rotation(float3 vertex)
            {
                float c = cos(_Time.y * _RotationSpeed);
                float s = sin(_Time.y * _RotationSpeed);
                
                float3x3 rotationMatrix = float3x3(c, 0, s,
                                                   0, 1, 0,
                                                  -s, 0, c);

                return mul(rotationMatrix, vertex);
            }

            
            v2f vert(appdata v)
            {
                v2f o;

                // TODO: Rotation not working with Fresnel effect.
                // float3 vertex_rotated = rotation(v.vertex);
                // o.vertex = UnityObjectToClipPos(vertex_rotated);

                o.vertex = UnityObjectToClipPos(v.vertex);

                const float3 view_dir = normalize(ObjSpaceViewDir(v.vertex));
                const float dot_product = 1 - dot(v.normal, view_dir);
                o.color = smoothstep(1 - _WaterFresnelWidth, 1, dot_product) * _WaterFresnelColor;
                
                o.uv = TRANSFORM_TEX(v.uv, _LandTex);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Land.
                fixed4 lands_mask = tex2D(_LandTex, i.uv);
                #if _INVERSELANDMAP_ON
                    lands_mask = 1 - lands_mask;
                #endif

                // Water.
                const fixed4 water_mask = 1 - lands_mask;
                // Voronoi noise.
                float angle_offset_time = _Time.y * _AngleOffsetSpeed;
                float voronoi_out = 0;
                float voronoi_cells = 0;
                voronoi_float(i.uv, _AngleOffset + angle_offset_time, _CellDensity, voronoi_out, voronoi_cells);
                voronoi_out = pow(voronoi_out, _WaterNoiseSharpness); // Sharpen voronoi.
                float4 voronoi_colored = lerp(_WaterCellsColor, _WaterVeinsColor, voronoi_out);
                voronoi_colored.rgb += i.color;
                const float4 water_color = water_mask * voronoi_colored;

                // Land Height.
                const fixed4 lands_height_mask = tex2D(_LandHeightTex, i.uv);
                const fixed4 lands_color = lerp(_LandColorA, _LandColorB, lands_height_mask) * lands_mask;

                // Waves.
                fixed4 waves_mask = tex2D(_ShoreWavesTex, i.uv);
                fixed4 waves_color = get_wave(waves_mask.r, _ShoreWavesSpeed);
                waves_color *= waves_mask * water_mask;
                waves_color *= _ShoreWavesColor;
                
                // Boundaries.
                const fixed4 boundaries_mask = tex2D(_BoundariesTex, i.uv);
                const fixed4 boundaries_color = (boundaries_mask * _BoundariesColor) * lands_mask;
                
                // Final color.
                fixed4 final_color = lands_color + water_color + waves_color + boundaries_color;
                return final_color;
            }
            
            ENDCG
        }
    }
}
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
        
        [Header(WATER)]
        [Space(5)]
        _WaterColor ("Water Color", Color) = (0,0,1,1)
        _ShoreWavesTex ("Shore Waves Map", 2D) = "white" {}
        _ShoreWavesSpeed ("Shore Waves Speed", Range(0, 10)) = 1
        _ShoreWavesColor ("Shore Waves Color", Color) = (1,1,1,1)
                
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

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
            
            sampler2D _LandTex;
            float4 _LandTex_ST;
            sampler2D _LandHeightTex;
            sampler2D _IceLandTex;
            sampler2D _ShoreWavesTex;
            sampler2D _BoundariesTex;

            float4 _LandColorA;
            float4 _LandColorB;
            float4 _WaterColor;
            float4 _ShoreWavesColor;
            float4 _BoundariesColor;
            
            float _ShoreWavesSpeed;
            float _RotationSpeed;
            
            float3 rotation (float3 vertex)
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

                float3 vertex_rotated = rotation(v.vertex);
                o.vertex = UnityObjectToClipPos(vertex_rotated);
                
                o.uv = TRANSFORM_TEX(v.uv, _LandTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Land.
                float4 lands_mask = tex2D(_LandTex, i.uv);
                #if _INVERSELANDMAP_ON
                    lands_mask = 1 - lands_mask;
                #endif

                // Water.
                const float4 water_mask = 1 - lands_mask;
                const float4 water_color = water_mask * _WaterColor;

                // Land Height.
                const float4 lands_height_mask = tex2D(_LandHeightTex, i.uv);
                const float4 lands_color = lerp(_LandColorA, _LandColorB, lands_height_mask) * lands_mask;

                // Waves.
                float4 waves_mask = tex2D(_ShoreWavesTex, i.uv);
                float4 waves_color = get_wave(waves_mask.r, _ShoreWavesSpeed);
                waves_color *= waves_mask * water_mask;
                waves_color *= _ShoreWavesColor;
                
                // Boundaries.
                const float4 boundaries_mask = tex2D(_BoundariesTex, i.uv);
                const float4 boundaries_color = (boundaries_mask * _BoundariesColor) * lands_mask;
                
                return lands_color + water_color + waves_color + boundaries_color;
            }
            ENDCG
        }
    }
}
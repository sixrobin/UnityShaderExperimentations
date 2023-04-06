Shader "EXO/EXO_Planet_Noise"
{
    Properties
    {
        _LandTex ("Land Map", 2D) = "white" {}
        _LandStep ("Land Step", Range(0, 1)) = 0.5
        _IslandTex ("Island Map", 2D) = "white" {}
        _IslandStep ("Island Step", Range(0, 1)) = 0.5
        _RotationSpeed ("Rotation Speed", Range(0, 45)) = 1
        _GroundWaterSmoothing ("Ground/Water Smoothing", Range(0, 0.5)) = 0.1
        _ColorWater ("Color Water", Color) = (0,0,1,1)
        _ColorGround ("Color Ground", Color) = (0,1,0,1)
        
        [Header(Shore)]
        [Space(5)]
        _ShoreColor ("Shore Color", Color) = (1,1,1,1)
        _ShoreModulo ("Shore Modulo", Range(0.9, 1)) = 0.99
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

            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex     : POSITION;
                float2 uv         : TEXCOORD0;
                float2 uv_islands : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv         : TEXCOORD0;
                float2 uv_islands : TEXCOORD1;
                float4 vertex     : SV_POSITION;
            };
            
            sampler2D _LandTex;
            float4 _LandTex_ST;
            sampler2D _IslandTex;
            float4 _IslandTex_ST;
            
            float4 _ColorWater;
            float4 _ColorGround;
            float _LandStep;
            float _IslandStep;
            float _GroundWaterSmoothing;
            float _RotationSpeed;

            // Shore.
            float4 _ShoreColor;
            float _ShoreModulo;
            
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

                float3 rotatedVertex = rotation(v.vertex);
                o.vertex = UnityObjectToClipPos(rotatedVertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _LandTex);
                o.uv_islands = TRANSFORM_TEX(v.uv_islands, _IslandTex);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 lands_map = tex2D(_LandTex, i.uv);
                float4 island_map = tex2D(_IslandTex, i.uv_islands);

                lands_map = smoothstep(lands_map - _GroundWaterSmoothing, lands_map + _GroundWaterSmoothing, _LandStep);
                island_map = smoothstep(island_map - _GroundWaterSmoothing, island_map + _GroundWaterSmoothing, _IslandStep);
                const float4 ground_map = island_map * lands_map;

                // Shore.
                fixed4 shore_mask = ground_map % _ShoreModulo;
                
                float4 color_map = lerp(_ColorGround, _ColorWater, ground_map);
                color_map += shore_mask * _ShoreColor;
                
                return color_map;
            }
            ENDCG
        }
    }
}
Shader "EXO/EXO_ToonFire"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FireDetail ("Fire Detail", Range(1, 20)) = 10
        _FirePower ("Fire Power", Range(0, 1)) = 0.5
        _FireColor ("Fire Color", Color) = (1, 1, 1, 1)
        _FireColorBurn ("Fire Color Burn", Range(1, 10)) = 3
        _FireSpeed ("Fire Speed", Range(0, 10)) = 1
        _BottomFadeWidth ("Bottom Fade Width", Range(0, 0.5)) = 0.1
        _BottomFadeSmooth ("Bottom Fade Smooth", Range(0, 0.5)) = 0.1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        Blend One One
        Cull Off

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            
            float noise_random_value(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float noise_interpolate(float a, float b, float t)
            {
                return (1.0 - t) * a + (t * b);
            }

            float value_noise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);

                float2 c0 = i + float2(0, 0);
                float2 c1 = i + float2(1, 0);
                float2 c2 = i + float2(0, 1);
                float2 c3 = i + float2(1, 1);
                float r0 = noise_random_value(c0);
                float r1 = noise_random_value(c1);
                float r2 = noise_random_value(c2);
                float r3 = noise_random_value(c3);

                float bottomOfGrid = noise_interpolate(r0, r1, f.x);
                float topOfGrid = noise_interpolate(r2, r3, f.x);
                return noise_interpolate(bottomOfGrid, topOfGrid, f.y);
            }

            float simple_noise(float2 uv, float scale)
            {
                float t = 0.0;

                float frequency = pow(2.0, float(0));
                float amplitude = pow(0.5, float(3-0));
                t += value_noise(float2(uv.x * scale / frequency, uv.y * scale / frequency)) * amplitude;

                frequency = pow(2.0, float(1));
                amplitude = pow(0.5, float(3-1));
                t += value_noise(float2(uv.x * scale / frequency, uv.y * scale / frequency)) * amplitude;

                frequency = pow(2.0, float(2));
                amplitude = pow(0.5, float(3 - 2));
                t += value_noise(float2(uv.x * scale / frequency, uv.y * scale / frequency)) * amplitude;

                return t;
            }


            float2 voronoi_noise_random_vector(float2 uv, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                uv = frac(sin(mul(uv, m)) * 46839.32);
                return float2(sin(uv.y * offset) * 0.5 + 0.5, cos(uv.x * offset) * 0.5 + 0.5);
            }

            void voronoi_float(float2 uv, float angle_offset, float cell_density, out float Out, out float Cells)
            {
                float2 g = floor(uv * cell_density);
                float2 f = frac(uv * cell_density);
                float3 res = float3(8.0, 0.0, 0.0);

                for (int y = -1; y <= 1; ++y)
                {
                    for (int x = -1; x <= 1; ++x)
                    {
                        float2 lattice = float2(x, y);
                        float2 offset = voronoi_noise_random_vector(lattice + g, angle_offset);
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _FireDetail;
            half _FirePower;
            fixed4 _FireColor;
            half _FireColorBurn;
            half _FireSpeed;
            half _BottomFadeWidth;
            half _BottomFadeSmooth;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Noise.
                float noise = simple_noise(i.uv - float2(0, _Time.y * _FireSpeed), _FireDetail);

                // Voronoi.
                float2 voronoi_lerp = lerp(i.uv, noise, 0.5);
                float voronoi_out = 0;
                float voronoi_cells = 0;
                voronoi_float(voronoi_lerp, 2, _FireDetail, voronoi_out, voronoi_cells);

                // Distortion.
                float2 lerp_factor = float2(0, _FirePower);
                float2 uv_distorted = lerp(i.uv, noise * voronoi_out, lerp_factor);
                
                fixed4 fire = tex2D(_MainTex, uv_distorted);

                // Bottom fade.
                float bottom_fade_mask = smoothstep(_BottomFadeWidth - _BottomFadeSmooth, _BottomFadeWidth + _BottomFadeSmooth, i.uv.y);
                fire = saturate(fire * bottom_fade_mask);
                
                return fire * _FireColor  * _FireColorBurn;
            }
            
            ENDCG
        }
    }
}

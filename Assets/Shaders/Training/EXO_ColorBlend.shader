Shader "EXO/EXO_ColorBlend"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0, 0, 0, 1)
        [KeywordEnum(Normal, Add, Average, ColorBurn, ColorDodge, Darken, Difference, Exclusion, Glow, HardLight, Lighten, LinearBurn, LinearDodge, LinearLight, Multiply, Negation, Overlay, Phoenix, PinLight, Reflect, Screen, SoftLight, Subtract, VividLight, HardMix)]
        _Blend ("Blend Mode", float) = 0
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
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile _BLEND_NORMAL _BLEND_ADD _BLEND_AVERAGE _BLEND_COLORBURN _BLEND_COLORDODGE _BLEND_DARKEN _BLEND_DIFFERENCE _BLEND_EXCLUSION _BLEND_GLOW _BLEND_HARDLIGHT _BLEND_LIGHTEN _BLEND_LINEARBURN _BLEND_LINEARDODGE _BLEND_LINEARLIGHT _BLEND_MULTIPLY _BLEND_NEGATION _BLEND_NORMAL _BLEND_OVERLAY _BLEND_PHOENIX _BLEND_PINLIGHT _BLEND_REFLECT _BLEND_SCREEN _BLEND_SOFTLIGHT _BLEND_SUBTRACT _BLEND_VIVIDLIGHT _BLEND_HARDMIX
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };


            fixed3 add(fixed3 a, fixed3 b)
            {
                return min(a + b, 1.0);
            }
            fixed3 average(fixed3 a, fixed3 b)
            {
                return (a + b) / 2.0;
            }
            fixed3 colorBurn(fixed3 a, fixed3 b)
            {
                return b == 0.0 ? b : max((1.0 - ((1.0 - a) / b)), 0.0);
            }
            fixed3 colorDodge(fixed3 a, fixed3 b)
            {
                return b == 1.0 ? b : min(a / (1.0 - b), 1.0);
            }
            fixed3 darken(fixed3 a, fixed3 b)
            {
                return min(a, b);
            }
            fixed3 difference(fixed3 a, fixed3 b)
            {
                return abs(a - b);
            }
            fixed3 exclusion(fixed3 a, fixed3 b)
            {
                return a + b - 2.0 * a * b;
            }
            fixed3 glow(fixed3 a, fixed3 b)
            {
                return (a == 1.0) ? a : min(b * b / (1.0 - a), 1.0);
            }
            fixed3 hardLight(fixed3 a, fixed3 b)
            {
                return b < 0.5 ? (2.0 * a * b) : (1.0 - 2.0 * (1.0 - a) * (1.0 - b));
            }
            fixed3 lighten(fixed3 a, fixed3 b)
            {
                return max(a, b);
            }
            fixed3 linearBurn(fixed3 a, fixed3 b)
            {
                return max(a + b - 1.0, 0.0);
            }
            fixed3 linearDodge(fixed3 a, fixed3 b)
            {
                return min(a + b, 1.0);
            }
            fixed3 linearLight(fixed3 a, fixed3 b)
            {
                return b < 0.5 ? linearBurn(a, (2.0 * b)) : linearDodge(a, (2.0 * (b - 0.5)));
            }
            fixed3 multiply(fixed3 a, fixed3 b)
            {
                return a * b;
            }
            fixed3 negation(fixed3 a, fixed3 b)
            {
                return 1.0 - abs(1.0 - a - b);
            }
            fixed3 normal(fixed3 a, fixed3 b)
            {
                return b;
            }
            fixed3 overlay(fixed3 a, fixed3 b)
            {
                return a < 0.5 ? (2.0 * a * b) : (1.0 - 2.0 * (1.0 - a) * (1.0 - b));
            }
            fixed3 phoenix(fixed3 a, fixed3 b)
            {
                return min(a, b) - max(a, b) + 1.0;
            }
            fixed3 pinLight(fixed3 a, fixed3 b)
            {
                return (b < 0.5) ? darken(a, (2.0 * b)) : lighten(a, (2.0 * (b - 0.5)));
            }
            fixed3 reflect(fixed3 a, fixed3 b)
            {
                return (b == 1.0) ? b : min(a * a / (1.0 - b), 1.0);
            }
            fixed3 screen(fixed3 a, fixed3 b)
            {
                return 1.0 - (1.0 - a) * (1.0 - b);
            }
            fixed3 softLight(fixed3 a, fixed3 b)
            {
                return (b < 0.5) ? (2.0 * a * b + a * a * (1.0 - 2.0 * b)) : (sqrt(a) * (2.0 * b - 1.0) + (2.0 * a) * (1.0 - b));
            }
            fixed3 subtract(fixed3 a, fixed3 b)
            {
                return max(a + b - 1.0, 0.0);
            }
            fixed3 vividLight(fixed3 a, fixed3 b)
            {
                return (b < 0.5) ? colorBurn(a, (2.0 * b)) : colorDodge(a, (2.0 * (b - 0.5)));
            }
            fixed3 hardMix(fixed3 a, fixed3 b)
            {
                return vividLight(a, b) < 0.5 ? 0.0 : 1.0;
            }

            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 tex_color = tex2D(_MainTex, i.uv);

                fixed4 blend_color = fixed4(0, 0, 0, 0);
                #if _BLEND_ADD
                    blend_color = fixed4(add(tex_color, _Color), 1);
                #elif _BLEND_AVERAGE
                    blend_color = fixed4(average(tex_color, _Color), 1);
                #elif _BLEND_COLORBURN
                    blend_color = fixed4(colorBurn(tex_color, _Color), 1);
                #elif _BLEND_COLORDODGE
                    blend_color = fixed4(colorDodge(tex_color, _Color), 1);
                #elif _BLEND_DARKEN
                    blend_color = fixed4(darken(tex_color, _Color), 1);
                #elif _BLEND_DIFFERENCE
                    blend_color = fixed4(difference(tex_color, _Color), 1);
                #elif _BLEND_EXCLUSION
                    blend_color = fixed4(exclusion(tex_color, _Color), 1);
                #elif _BLEND_GLOW
                    blend_color = fixed4(glow(tex_color, _Color), 1);
                #elif _BLEND_HARDLIGHT
                    blend_color = fixed4(hardLight(tex_color, _Color), 1);
                #elif _BLEND_LIGHTEN
                    blend_color = fixed4(lighten(tex_color, _Color), 1);
                #elif _BLEND_LINEARBURN
                    blend_color = fixed4(linearBurn(tex_color, _Color), 1);
                #elif _BLEND_LINEARDODGE
                    blend_color = fixed4(linearDodge(tex_color, _Color), 1);
                #elif _BLEND_LINEARLIGHT
                    blend_color = fixed4(linearLight(tex_color, _Color), 1);
                #elif _BLEND_MULTIPLY
                    blend_color = fixed4(multiply(tex_color, _Color), 1);
                #elif _BLEND_NEGATION
                    blend_color = fixed4(negation(tex_color, _Color), 1);
                #elif _BLEND_OVERLAY
                    blend_color = fixed4(overlay(tex_color, _Color), 1);
                #elif _BLEND_PHOENIX
                    blend_color = fixed4(phoenix(tex_color, _Color), 1);
                #elif _BLEND_PINLIGHT
                    blend_color = fixed4(pinLight(tex_color, _Color), 1);
                #elif _BLEND_REFLECT
                    blend_color = fixed4(reflect(tex_color, _Color), 1);
                #elif _BLEND_SCREEN
                    blend_color = fixed4(screen(tex_color, _Color), 1);
                #elif _BLEND_SOFTLIGHT
                    blend_color = fixed4(softLight(tex_color, _Color), 1);
                #elif _BLEND_SUBTRACT
                    blend_color = fixed4(subtract(tex_color, _Color), 1);
                #elif _BLEND_VIVIDLIGHT
                    blend_color = fixed4(vividLight(tex_color, _Color), 1);
                #elif _BLEND_HARDMIX
                    blend_color = fixed4(hardMix(tex_color, _Color), 1);
                #else
                    blend_color = fixed4(normal(tex_color, _Color), 1);
                #endif
                
                return lerp(tex_color, blend_color, _Color.a);
            }
            
            ENDCG
        }
    }
}
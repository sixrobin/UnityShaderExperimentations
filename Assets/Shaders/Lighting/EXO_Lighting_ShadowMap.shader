Shader "EXO/EXO_Lighting_ShadowMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowIntensity ("Shadow Intensity", Range(0, 1)) = 1
    }
    
    SubShader
    {
        LOD 100

        // Shadow caster pass.
        Pass
        {
            Name "Shadow Caster"
            
            Tags
            {
                "LightMode"="ShadowCaster"
            }
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            
            ENDCG
        }
        
        // Default color pass.
        Pass
        {
            Name "Shadow Map Texture"
            
            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ForwardBase"
            }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                SHADOW_COORDS(1)
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _ShadowIntensity;

            float4 NDCToUV(float4 clipPos)
            {
                float4 o = clipPos * 0.5;
                
                #if defined(UNITY_HALF_TEXEL_OFFSET)
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w * _ScreenParams.zw;
                #else
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
                #endif

                o.zw = clipPos.zw;
                return o;
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed shadow = SHADOW_ATTENUATION(i);
                col.rgb = lerp(col.rgb, col.rgb * shadow, _ShadowIntensity);
                
                return col;
            }
            
            ENDCG
        }
    }
}

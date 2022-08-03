Shader "EXO/EXO_Burn"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(BURN)]
        [Space(5)]
        _BurnTex ("Burn Texture", 2D) = "white" {}
        _BurnPosition ("Burn Position", Range(0, 1)) = 0.5
        _BurnWidth ("Burn Width", Range(0, 1)) = 0.1
        _BurnColor ("Burn Color", Color) = (1, 0, 0, 1)
        
        [Header(BURN LINE)]
        [Space(5)]
        _BurnLine1Width ("Burn Line 1 Width", Range(0, 0.5)) = 0.1
        _BurnLine1Color ("Burn Line 1 Color", Color) = (1, 0, 0, 1)
        _BurnLine2Width ("Burn Line 2 Width", Range(0, 0.5)) = 0.1
        _BurnLine2Color ("Burn Line 2 Color", Color) = (1, 0, 0, 1)
        
        [Header(MOTION)]
        [Space(5)]
        _SpeedX ("X", Range(-20, 20)) = 0
        _SpeedY ("Y", Range(-20, 20)) = 0
        
        [Header(BLEND)]
        [Space(5)]
        [Enum(UnityEngine.Rendering.BlendMode)]
        _ScrBlend ("Source Blend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("Destination Blend", float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }

        Blend [_ScrBlend] [_DstBlend]
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_burn : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_burn : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BurnTex;
            float4 _BurnTex_ST;

            float _BurnPosition;
            float _BurnWidth;
            half4 _BurnColor;
            float _BurnLine1Width;
            half4 _BurnLine1Color;
            float _BurnLine2Width;
            half4 _BurnLine2Color;

            float _SpeedX;
            float _SpeedY;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.uv_burn = TRANSFORM_TEX(v.uv_burn, _BurnTex);
                o.uv_burn.x += _Time.x * _SpeedX;
                o.uv_burn.y += _Time.x * _SpeedY;
                
                UNITY_TRANSFER_FOG(o, o.vertex);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float burn_blend = smoothstep(i.uv.y - _BurnWidth, i.uv.y + _BurnWidth, _BurnPosition);

                // Burn mask.
                fixed4 burn_tex = tex2D(_BurnTex, i.uv_burn);
                fixed4 burn_mask_base = burn_tex * burn_blend + burn_blend;
                fixed4 burn_mask_step = 1 - step(burn_mask_base, 0.5);
                fixed4 burn_mask_smoothstep = 1 - smoothstep(burn_mask_base - 0.1, burn_mask_base + 0.1, 0.45);
                fixed4 burn_mask = (1 - burn_mask_step) * (1 - burn_mask_smoothstep);
                burn_mask.a = ceil(burn_mask.r);

                // Burn line 1.
                fixed4 burn_line_1 = step(burn_mask, _BurnLine1Width);
                _BurnLine1Color.a = 0;
                fixed4 burn_line_color_1 = burn_line_1 * _BurnLine1Color;

                // Burn line 2.
                fixed4 burn_line_2 = step(burn_mask, _BurnLine2Width);
                _BurnLine2Color.a = 0;
                fixed4 burn_line_color_2 = burn_line_2 * _BurnLine2Color;

                // Burn color.
                fixed4 burn_color = _BurnColor;
                burn_color.a = burn_mask.a;
                burn_color *= 1 - burn_mask;
                
                fixed4 main_color = tex2D(_MainTex, i.uv);
                return main_color * burn_mask + burn_line_color_1 + burn_line_color_2 + burn_color;
            }
            
            ENDCG
        }
    }
}
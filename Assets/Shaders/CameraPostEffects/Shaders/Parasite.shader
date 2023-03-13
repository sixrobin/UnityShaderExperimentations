Shader "MyShaders/Parasite" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_VHSTex("Base (RGB)", 2D) = "gray" {}
		_frequency("Frequency", float) = 0
		_contrast("Contrast", float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	uniform sampler2D _MainTex;
	uniform sampler2D _backGround;

	float _frequency;
	float _contrast;

	struct v2f
	{
		float4 position : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	float rand(float3 co) 
	{
		return frac(sin(dot(co.xyz ,float3(13.1, 78.2, 45.5))) * 43758);
	}

	float4 frag(v2f i) : SV_Target
	{
		fixed4 bg = tex2D(_backGround, i.uv);

		float dx = 1 - abs(distance(i.uv.x, _frequency));
		float dy = 1 - abs(distance(i.uv.y, _contrast));

		dy = ((int)(dy * 8)) / 8.0;
		i.uv.y += dy * 0.025 + rand(float3(dy, dy, dy)).r / 500;
		i.uv.x += dx * 0.025 + rand(float3(dx, dx, dx)).r / 500;

		float white = (bg.r + bg.g + bg.b) / 3;

		if (dx > 0.99)
			i.uv.y = _frequency;

		i.uv.x = i.uv.x % 1;
		i.uv.y = i.uv.y % 1;

		fixed4 c = tex2D(_MainTex, i.uv);

		float bleed = tex2D(_MainTex, i.uv + float2(0.01, 0)).rgb;
		bleed += tex2D(_MainTex, i.uv + float2(0.01, 0.01)).r;
		bleed += tex2D(_MainTex, i.uv + float2(0.02, 0.02)).g;
		bleed += tex2D(_MainTex, i.uv + float2(0.03, 0.03)).b;
		bleed /= 6;

		float x = ((int)(i.uv.x * 320)) / 320.0;
		float y = ((int)(i.uv.y * 240)) / 240.0;

		c -= rand(float3(x, y, _frequency)) * _contrast / 5;

		return fixed4(bg + c);
	}
	ENDCG

	SubShader{
		Pass{
			ZTest Always Cull Off ZWrite Off
			Fog{ Mode off }

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest 
			ENDCG
		}
	}
}
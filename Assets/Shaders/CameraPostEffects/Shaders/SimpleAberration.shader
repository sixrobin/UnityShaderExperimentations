// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/SimpleAberration" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_aberration("Chromatic Aberration", float) = 0.5
	}
		
	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float _aberration;

	struct v2f 
	{
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;
	};

	v2f vert(appdata_img v) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}

	float4 frag(v2f i) : SV_Target
	{
		float4 sum = (float4)0;
		sum = tex2D(_MainTex, i.uv);

		float2 coords = i.uv;
		coords = (coords - 0.5) * 2.0;

		float2 offset = (float2)0;
		offset.x = coords.x * sqrt(_aberration / 1000);
		offset.y = coords.y * sqrt(_aberration / 1000);

		float red, green, blue = (float)0;
		red = tex2D(_MainTex, i.uv - offset * 3 * _aberration).r;
		green = tex2D(_MainTex, i.uv - offset * 5 * _aberration).g;
		blue = tex2D(_MainTex, i.uv - offset * 8 * _aberration).b;

		float4 ab = (float4)0;
		ab += (float4(red, 0, 0, 1) + float4(0, green, 0, 1) + float4(0, 0, blue, 1));
		ab *= 1.5;

		return fixed4(sum * ab);
	}

	ENDCG

	SubShader 
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			ENDCG
		}
	}
	Fallback off
}

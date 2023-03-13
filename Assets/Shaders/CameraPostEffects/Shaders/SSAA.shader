// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/SSAA" {

	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_mode("SSAA Mode", int) = 0
		_size("Size", int) = 512
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_ST;
	int _mode;
	int _size;

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv_MainTex : TEXCOORD0;
	};

	v2f vert(appdata_full v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}

	float4 frag(v2f i) :COLOR
	{
		float3 lum = float3(0.2125, 0.7154, 0.0721);

		float mc00 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(1, 1) / _size).rgb, lum);
		float mc10 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(0, 1) / _size).rgb, lum);
		float mc20 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(-1, 1) / _size).rgb, lum);
		float mc01 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(1, 0) / _size).rgb, lum);
		float mc11mc = dot(tex2D(_MainTex, i.uv_MainTex).rgb, lum);
		float mc21 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(-1, 0) / _size).rgb, lum);
		float mc02 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(1, -1) / _size).rgb, lum);
		float mc12 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(0, -1) / _size).rgb, lum);
		float mc22 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(-1, -1) / _size).rgb, lum);

		float GX = -1 * mc00 + mc20 + -2 * mc01 + 2 * mc21 - mc02 + mc22;
		float GY = mc00 + 2 * mc10 + mc20 - mc02 - 2 * mc12 - mc22;
		float G = abs(GX) + abs(GY);

		float4 c = 0;
		c = length(float2(GX, GY));

		float4 sum = tex2D(_MainTex, i.uv_MainTex);

		if (c.x < 0.2)
			return sum;
		else
		{
			float4 c0, c1, c2, c3 = (float4)0;

			if (_mode == 0)
			{
				c0 = tex2D(_MainTex, i.uv_MainTex + fixed2(0.2 / 2, 0.8) / _size);
				c1 = tex2D(_MainTex, i.uv_MainTex + fixed2(0.8 / 2, -0.2) / _size);
				c2 = tex2D(_MainTex, i.uv_MainTex + fixed2(-0.2 / 2, -0.8) / _size);
				c3 = tex2D(_MainTex, i.uv_MainTex + fixed2(-0.8 / 2, 0.2) / _size);
			}

			if (_mode == 1)
			{
				c0 = tex2D(_MainTex, i.uv_MainTex + fixed2(0.5, 1) / _size);
				c1 = tex2D(_MainTex, i.uv_MainTex + fixed2(-0.5, 1) / _size);
				c2 = tex2D(_MainTex, i.uv_MainTex + fixed2(0.5, -1) / _size);
				c3 = tex2D(_MainTex, i.uv_MainTex + fixed2(-0.5, -1) / _size);
			}

			sum = (sum + c0 + c1 + c2 + c3) * 0.2;

			return sum;
		}
	}

	ENDCG

	SubShader 
	{
		pass 
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
	Fallback off
}

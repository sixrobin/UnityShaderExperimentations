// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Zebra" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_size("Stripes Size", float) = 0.5
		_saturation("Saturation", float) = 1
		_speed("Speed", float) = 1
		_axis("Direction", int) = 0
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _size;
	float _saturation;
	float _timer;
	float _speed;
	int _axis;
	
	v2f vert( appdata_img v ) 
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

		float4 stripes = (float4)0;
	    stripes = tex2D(_MainTex, i.uv);

		if (_axis == 0)
			stripes.rgb = stripes.rgb * sin(i.uv.y * 1000 * _size + _Time.z * _speed) * _saturation;
		if (_axis == 1)
			stripes.rgb = stripes.rgb * sin(i.uv.x * 1000 * _size + _Time.z * _speed) * _saturation;

		sum += stripes;
		sum /= 2;

	    return fixed4(sum);
	}

	ENDCG

	SubShader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			Fog{ Mode off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0
			ENDCG
		}
	}
}

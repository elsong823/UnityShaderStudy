Shader "MyShader/c7/tangentNormalMap"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = "white"{}
		_BumpMap("BumpMap", 2D) = "bump"{}
		_BumpScale("BumpScale", Float) = 1.0
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8, 256)) = 128
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 tangentLight : TEXCOORD1;
				float3 tangentView : TEXCOORD2;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			v2f Vert(in a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = TRANSFORM_TEX(i.texcoord, _BumpMap);

				fixed3 worldNormal = UnityObjectToWorldNormal( i.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( i.tangent.xyz );
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * i.tangent.w;

				float3x3 matRotate = float3x3(worldTangent, worldBinormal, worldNormal);

				o.tangentLight = mul( matRotate, WorldSpaceLightDir(i.vertex) );
				o.tangentView = mul( matRotate, WorldSpaceViewDir(i.vertex) );

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed3 tangentLight = normalize( i.tangentLight );
				fixed3 tangentView = normalize( i.tangentView );
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt( 1.0 - saturate( dot(tangentNormal.xy, tangentNormal.xy) ) );
				fixed3 tangentHalf = normalize(tangentLight + tangentView);

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0 * albedo * saturate( dot(tangentLight, tangentNormal) );

				fixed3 specular = _LightColor0 * _Specular * pow(saturate( dot(tangentNormal, tangentHalf) ), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"

}
package com.yogurt3d.core.plugin
{
	import flash.utils.Dictionary;

	public class Kernel
	{
		private static var m_instance:Kernel;
		
		private var m_serverDict:Dictionary;
		
		public function Kernel(_enforcer:SingletonEnforcer)
		{
			m_serverDict = new Dictionary();
		}
		
		public static function get instance():Kernel{
			if( m_instance == null )
			{
				m_instance = new Kernel(new SingletonEnforcer());
			}
			return m_instance;
		}
		
		public function getServer( _serverName:String):Server{
			return m_serverDict[_serverName];
		}
		
		public function addServer( _server:Server):Boolean{
			m_serverDict[ _server.name ] = _server;
			return true;
		}
		
		public function loadPluginFromClass( _class:Class ):Boolean{
			if( _class != null )
			{
				var plugin:Plugin = new _class();
				if( plugin )
				{
					return plugin.registerPlugin( this );
				}
			}
			return false;
		}
		public function loadPluginFromObject( _plugin:Plugin ):Boolean{
			if( _plugin )
			{
				return _plugin.registerPlugin( this );
			}
			return false;
		}
		public function loadPluginFromFile( _url:String, _className:String):Boolean{
			return false;
		}
		
		
	}
}
internal class SingletonEnforcer {}
# Copyright (c) 2012 Jakub Pastuszek
#
# This file is part of Distributed Monitoring System.
#
# Distributed Monitoring System is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Distributed Monitoring System is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Distributed Monitoring System.  If not, see <http://www.gnu.org/licenses/>.
#
module Navigation
	class CantDetermineRootError < RuntimeError
	end

	def root_uri(*parts)
		raise CantDetermineRootError, 'no ROOT_SCRIPT_NAME env defined, please use Rack::RootScriptName middleware' unless env.has_key? 'ROOT_SCRIPT_NAME'
		build_uri(env['ROOT_SCRIPT_NAME'], *parts)
	end

	def relative_uri(*parts)
		build_uri(env['SCRIPT_NAME'], *parts)
	end

	def uri
		env['SCRIPT_NAME'] + env['PATH_INFO']
	end

	def go_to(*parts)
		res.redirect(root_uri(*parts))
	end

	def build_uri(*parts)
		out = Pathname.new(parts.shift)
		query = {}
		parts.each do |part|
			if part.is_a? Hash
				query.merge! part
			else
				out += Rack::Utils.escape(part)
			end
		end
		out = out.expand_path.to_s

		unless query.empty?
			out += '?' + query.map{|k,v| "#{k}=#{v}"}.join('&')
		end

		out
	end
end


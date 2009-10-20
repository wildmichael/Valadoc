/*
 * Valadoc.Api.- a documentation tool for vala.
 * Copyright (C) 2008 Florian Brosch
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

using Gee;
using Valadoc.Content;

public class Valadoc.Api.Namespace : Symbol {
	private Vala.Comment source_comment;

	public Namespace (Vala.Namespace symbol, Api.Node parent) {
		base (symbol, parent);

		this.vnspace = symbol;

		if (vnspace.source_reference != null) {
			foreach (Vala.Comment c in vnspace.get_comments()) {
				if (this.package.is_vpackage (c.source_reference.file)) {
					this.source_comment = c;
					break;
				}
			}
		}
	}

	protected override void process_comments (Settings settings, DocumentationParser parser) {
		if (source_comment != null) {
			documentation = parser.parse (this, source_comment);
		}

		base.process_comments (settings, parser);
	}

	protected override Inline build_signature () {
		return new SignatureBuilder ()
			.append_keyword (get_accessibility_modifier ())
			.append_keyword ("namespace")
			.append_symbol (this)
			.get ();
	}

	public override NodeType node_type { get { return NodeType.NAMESPACE; } }

	public override void accept (Visitor visitor) {
		visitor.visit_namespace (this);
	}

	public Vala.Namespace vnspace {
		private get;
		set;
	}
}

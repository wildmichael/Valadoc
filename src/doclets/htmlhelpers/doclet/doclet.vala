/*
 * Valadoc - a documentation tool for vala.
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

using GLib;
using Valadoc.Content;
using Valadoc.Api;

public abstract class Valadoc.Html.BasicDoclet : Api.Visitor, Doclet {
	protected Settings settings;
	protected HtmlRenderer _renderer;
	protected MarkupWriter writer;

	public abstract void process (Settings settings, Api.Tree tree);

	protected string? get_link (Api.Node element, Api.Node? pos) {
		return get_html_link (this.settings, element, pos);
	}

	protected void write_navi_entry_html_template (string style, string content) {
		writer.start_tag ("li", style);
		writer.text (content);
		writer.end_tag ("li");
	}

	protected void write_navi_entry_html_template_with_link (string style, string link, string content) {
		writer.start_tag ("li", style);
		writer.link (link, content);
		writer.end_tag ("li");
	}

	protected void write_navi_entry (Api.Node element, Api.Node? pos, string style, bool link, bool full_name = false) {
		string name;

		if (full_name == true && element is Namespace) {
			string tmp = element.full_name();
			name = (tmp == null)? "Global Namespace" : tmp;
		}
		else {
			string tmp = element.name;
			name = (tmp == null)? "Global Namespace" : tmp;
		}

		if (link == true)
			this.write_navi_entry_html_template_with_link (style, this.get_link (element, pos), name);
		else
			this.write_navi_entry_html_template (style, name);
	}

	protected void write_wiki_pages (Api.Tree tree, string css_path_wiki, string contentp) {
		if (tree.wikitree == null) {
			return ;
		}

		if (tree.wikitree == null) {
			return ;
		}

		Gee.Collection<WikiPage> pages = tree.wikitree.get_pages();
		if (pages.size == 0) {
			return ;
		}

		DirUtils.create (contentp, 0777);

		DirUtils.create (Path.build_filename (contentp, "img"), 0777);

		foreach (WikiPage page in pages) {
			if (page.name != "index.valadoc") {
				GLib.FileStream file = GLib.FileStream.open (Path.build_filename(contentp, page.name.ndup(page.name.len()-7).replace ("/", ".")+"html"), "w");
				writer = new MarkupWriter (file);
				_renderer.set_writer (writer);
				this.write_file_header (css_path_wiki, this.settings.pkg_name);
				_renderer.set_container (page);
				_renderer.render (page.documentation);
				this.write_file_footer ();
			}
		}
	}

	protected void write_navi_top_entry (Api.Node element, Api.Node? parent) {
		string name = (element.name == null)? "Global Namespace" : element.name;
		string style = null;

		if (element is Namespace)
			style = css_namespace;
		else if (element is Enum)
			style = css_enum;
		else if (element is ErrorDomain)
			style = css_errordomain;
		else if (element is Struct)
			style = css_struct;
		else if (element is Class)
			style = (((Class)element).is_abstract)? css_abstract_class : css_class;
		else if (element is Interface)
			style = css_interface;
		else if (element is Package) {
			name = element.package.name;
			style = css_package;
		}

		writer.start_tag ("ul", css_navi);

		if (element == parent || parent == null)
			this.write_navi_entry (element, parent, style, false);
		else
			this.write_navi_entry (element, parent, style, true);

		writer.end_tag ("ul");
		writer.simple_tag ("hr", css_navi_hr);
	}

	protected void write_top_element_template (string link) {
		writer.start_tag ("ul", css_navi);
		writer.start_tag ("li", css_package_index);
		writer.link (link, "Packages");
		writer.end_tag ("li");
		writer.end_tag ("ul");
		writer.simple_tag ("hr", css_navi_hr);
	}

	protected void write_top_elements (Api.Node element, Api.Node? parent) {
		Gee.ArrayList<Api.Node> lst = new Gee.ArrayList<Api.Node> ();
		Api.Node pos = element;

		this.write_top_element_template ("../index.html");

		while (pos != null) {
			lst.add (pos);
			pos = (Api.Node)pos.parent;
		}

		for (int i = lst.size-1; i >= 0  ; i--) {
			Api.Node el = lst.get (i);

			if (el.name != null) {
				this.write_navi_top_entry (el, parent);
			}
		}
	}

	protected void fetch_subnamespace_names (NamespaceHandler pos, Gee.ArrayList<Namespace> lst) {
		Gee.Collection<Namespace> nspaces = pos.get_namespace_list ();

		foreach (Namespace ns in nspaces) {
			lst.add (ns);
			this.fetch_subnamespace_names (ns, lst);
		}
	}

	protected void write_navi_file (Package efile, Api.Node? pos) {
		Gee.ArrayList<Namespace> ns_list = new Gee.ArrayList<Namespace> ();
		this.fetch_subnamespace_names (efile, ns_list);


		writer.start_tag ("div", css_style_navigation);


		if (pos == null)
			this.write_top_elements (efile, null);
		else if (pos == efile)
			this.write_top_elements (efile, efile);
		else
			this.write_top_elements ((Api.Node)pos.parent.parent, pos);

		writer.start_tag ("ul", css_navi);


		Namespace globals = null;

		foreach (Namespace ns in ns_list) {
			if (ns.name == null)
				globals = ns;
			else
				this.write_navi_entry (ns, pos, css_namespace, true, true);
		}

		if (globals != null) {
			this.write_navi_child_namespaces_inline_withouth_block (globals, pos);
		}

		writer.end_tag ("ul");
		writer.end_tag ("div");
	}

	protected void write_navi_child_namespaces_inline_withouth_block (Namespace ns, Api.Node? parent) {
		this.write_navi_child_namespaces_without_childs (ns, parent);
		this.write_navi_child_classes_without_childs (ns, parent);
		this.write_navi_child_interfaces_without_childs (ns, parent);
		this.write_navi_child_structs_without_childs (ns, parent);
		this.write_navi_child_enums_without_childs (ns, parent);
		this.write_navi_child_error_domains_without_childs (ns, parent);
		this.write_navi_child_delegates (ns, parent);
		this.write_navi_child_static_methods (ns, parent);
		this.write_navi_child_methods (ns, parent);
		this.write_navi_child_fields (ns, parent);
		this.write_navi_child_constants (ns, parent);
	}

	protected void write_navi_child_namespaces_inline (Namespace ns, Api.Node? parent) {
		writer.start_tag ("ul", css_navi);

		if (ns.name == null) {
			this.write_navi_child_namespaces_without_childs ((Package)ns.parent, ns);
		}

		this.write_navi_child_namespaces_inline_withouth_block (ns, parent);

		writer.end_tag ("ul");
	}

	protected void write_navi_child_namespaces (Namespace ns, Api.Node? parent) {
		this.write_top_elements (ns, parent);
		this.write_navi_child_namespaces_inline (ns, parent);
	}

	protected void write_navi_struct_inline (Struct stru, Api.Node? parent) {
		writer.start_tag ("ul", css_navi);
		this.write_navi_child_construction_methods (stru, parent);
		this.write_navi_child_static_methods (stru, parent);
		this.write_navi_child_methods (stru, parent);
		this.write_navi_child_fields (stru, parent);
		this.write_navi_child_constants (stru, parent);
		writer.end_tag ("ul");
	}

	protected void write_navi_struct (Struct stru, Api.Node? parent) {
		writer.start_tag ("div", css_style_navigation);
		this.write_top_elements (stru, parent);
		this.write_navi_struct_inline (stru, parent);
		writer.end_tag ("div");
	}

	protected void write_navi_interface_inline (Interface iface, Api.Node? parent) {
		writer.start_tag ("ul", css_navi);
		this.write_navi_child_static_methods (iface, parent);
		this.write_navi_child_delegates (iface, parent);
		this.write_navi_child_methods (iface, parent);
		this.write_navi_child_signals (iface, parent);
		this.write_navi_child_properties (iface, parent);
		this.write_navi_child_fields (iface, parent);
		this.write_navi_child_constants (iface, parent);
		writer.end_tag ("ul");
	}

	protected void write_navi_interface (Interface iface, Api.Node? parent) {
		writer.start_tag ("div", css_style_navigation);
		this.write_top_elements (iface, parent);
		this.write_navi_interface_inline (iface, parent);
		writer.end_tag ("div");
	}

	protected void write_navi_enum_inline (Enum en, Api.Node? parent) {
		Gee.Collection<Api.EnumValue> enum_values = en.get_enum_values ();
		writer.start_tag ("ul", css_navi);

		foreach (Api.EnumValue env in enum_values) {
			this.write_navi_entry (env, en, css_enumvalue, true);
		}

		this.write_navi_child_static_methods (en, parent);
		this.write_navi_child_methods (en, parent);
		writer.end_tag ("ul");
	}

	protected void write_navi_enum (Enum en, Api.Node? parent) {
		writer.start_tag ("div", css_style_navigation);
		this.write_top_elements (en, parent);
		this.write_navi_enum_inline (en, parent);
		writer.end_tag ("div");
	}

	protected void write_navi_error_domain_inline (ErrorDomain errdom, Api.Node? parent = null) {
		Gee.Collection<ErrorCode> error_codes = errdom.get_error_code_list ();
		writer.start_tag ("ul", css_navi);

		foreach (ErrorCode ec in error_codes) {
			this.write_navi_entry (ec, errdom, css_errorcode, true);
		}

		this.write_navi_child_static_methods (errdom, parent);
		this.write_navi_child_methods (errdom, parent);
		writer.end_tag ("ul");
	}

	protected void write_navi_namespace (Namespace ns) {
		writer.start_tag ("div", css_style_navigation);
		this.write_top_elements (ns, ns);
		this.write_navi_child_namespaces_inline (ns, ns);
		writer.end_tag ("div");
	}

	protected void write_navi_error_domain (ErrorDomain errdom, Api.Node? parent) {
		writer.start_tag ("div", css_style_navigation);
		this.write_top_elements (errdom, parent);
		this.write_navi_error_domain_inline (errdom, parent);
		writer.end_tag ("div");
	}

	protected void write_navi_class_inline (Class cl, Api.Node? parent) {
		writer.start_tag ("ul", css_navi);
		this.write_navi_child_construction_methods (cl, parent);
		this.write_navi_child_static_methods (cl, parent);
		this.write_navi_child_classes_without_childs (cl, parent);
		this.write_navi_child_structs_without_childs (cl, parent);
		this.write_navi_child_enums_without_childs (cl, parent);
		this.write_navi_child_delegates (cl, parent);
		this.write_navi_child_methods (cl, parent);
		this.write_navi_child_signals (cl, parent);
		this.write_navi_child_properties (cl, parent);
		this.write_navi_child_fields (cl, parent);
		this.write_navi_child_constants (cl, parent);
		writer.end_tag ("ul");
	}

	protected void write_navi_class (Class cl, Api.Node? parent) {
		writer.start_tag ("div", css_style_navigation);
		this.write_top_elements (cl, parent);
		this.write_navi_class_inline (cl, parent);
		writer.end_tag ("div");
	}

	protected void write_navi_method (Method m) {
		Api.Node parent = (Api.Node)m.parent;

		if (parent.name == null) {
			this.write_navi_file ((Package)parent.parent, m);
		}
		else {
			writer.start_tag ("div", css_style_navigation);

			this.write_top_elements (parent, m);

			if (parent is Class)
				this.write_navi_class_inline ((Class)parent, m);
			else if (m.parent is Interface)
				this.write_navi_interface_inline ((Interface)parent, m);
			else if (m.parent is Struct)
				this.write_navi_struct_inline ((Struct)parent, m);
			else if (m.parent is Enum)
				this.write_navi_enum_inline ((Enum)parent, m);
			else if (m.parent is ErrorDomain)
				this.write_navi_error_domain_inline ((ErrorDomain)parent, m);
			else if (m.parent is Namespace)
				this.write_navi_child_namespaces_inline ((Namespace)parent, m);

			writer.end_tag ("div");
		}
	}

	protected void write_navi_property (Property prop) {
		Api.Node parent = (Api.Node)prop.parent;

		writer.start_tag ("div", css_style_navigation);
		this.write_top_elements (parent, prop);

		if (parent is Class)
			this.write_navi_class_inline ((Class)parent, prop);
		else if (parent is Interface)
			this.write_navi_interface_inline ((Interface)parent, prop);

		writer.end_tag ("div");
	}

	protected void write_navi_signal (Api.Signal sig) {
		Api.Node parent = (Api.Node)sig.parent;

		writer.start_tag ("div", css_style_navigation);

		this.write_top_elements (parent, sig);

		if (parent is Class)
			this.write_navi_class_inline ((Class)parent, sig);
		else if (parent is Interface)
			this.write_navi_interface_inline ((Interface)parent, sig);

		writer.end_tag ("div");
	}

	protected void write_navi_constant (Constant c) {
		Api.Node parent = (Api.Node)c.parent;

		if (parent.name == null) {
			this.write_navi_file ((Package)parent.parent, c);
		}
		else {
			writer.start_tag ("div", css_style_navigation);
			this.write_top_elements (parent, c);

			if (parent is Class)
				this.write_navi_class_inline ((Class)parent, c);
			else  if (parent is Struct)
				this.write_navi_struct_inline ((Struct)parent, c);
			else  if (parent is Namespace)
				this.write_navi_child_namespaces_inline ((Namespace)parent, c);
			else if (parent is Interface)
				this.write_navi_interface_inline ((Interface)parent, c);

			writer.end_tag ("div");
		}
	}

	protected void write_navi_field (Field f) {
		Api.Node parent = (Api.Node)f.parent;

		if (parent.name == null) {
			this.write_navi_file ((Package)parent.parent, f);
		}
		else {
			writer.start_tag ("div", css_style_navigation);
			this.write_top_elements (parent, f);

			if (parent is Class)
				this.write_navi_class_inline ((Class)parent, f);
			else if (parent is Struct)
				this.write_navi_struct_inline ((Struct)parent, f);
			else if (parent is Namespace)
				this.write_navi_child_namespaces_inline ((Namespace)parent, f);
			else if (parent is Interface)
				this.write_navi_interface_inline ((Interface)parent, f);

			writer.end_tag ("div");
		}
	}

	protected void write_navi_delegate (Delegate del) {
		Api.Node parent = (Api.Node)del.parent;

		if (parent.name == null) {
			this.write_navi_file ((Package)parent.parent, del);
		}
		else {
			writer.start_tag ("div", css_style_navigation);
			this.write_top_elements (parent, del);

			if (parent is Namespace)
				this.write_navi_child_namespaces_inline ((Namespace)parent, del);
			else if (parent is Class)
				this.write_navi_class_inline ((Class)parent, del);
			else if (parent is Interface)
				this.write_navi_interface_inline ((Interface)parent, del);

			writer.end_tag ("div");
		}
	}

	protected void write_navi_child_methods_collection (Gee.Collection<Method> methods, Api.Node? parent) {
		foreach (Method m in methods) {
			if (!m.is_static) {
				string css;
				if (m.is_virtual || m.is_override)
					css = css_virtual_method;
				else if (m.is_abstract)
					css = css_abstract_method;
				else
					css = css_method;

				if (m == parent)
					this.write_navi_entry (m, parent, css, false);
				else
					this.write_navi_entry (m, parent, css, true);
			}
		}
	}

	protected void write_navi_child_construction_methods_collection (Gee.Collection<Method> methods, Api.Node? parent) {
		foreach (Method m in methods) {
			if (m == parent)
				this.write_navi_entry (m, parent, css_creation_method, false);
			else
				this.write_navi_entry (m, parent, css_creation_method, true);
		}
	}

	protected void write_navi_child_static_methods_collection (Gee.Collection<Method> methods, Api.Node? parent) {
		foreach (Method m in methods) {
			if (m.is_static) {
				if (m == parent)
					this.write_navi_entry (m, parent, css_static_method, false);
				else
					this.write_navi_entry (m, parent, css_static_method, true);
			}
		}
	}

	protected void write_navi_child_methods (MethodHandler mh, Api.Node? parent) {
		Gee.Collection<Method> methods = mh.get_method_list ();
		this.write_navi_child_methods_collection (methods, parent);
	}

	protected void write_navi_child_static_methods (MethodHandler mh, Api.Node? parent) {
		Gee.Collection<Method> methods = mh.get_method_list ();
		this.write_navi_child_static_methods_collection (methods, parent);
	}

	protected void write_navi_child_classes_without_childs_collection (Gee.Collection<Class> classes, Api.Node? parent) {
		foreach (Class cl in classes) {
			if (cl == parent)
				this.write_navi_entry (cl, parent, (cl.is_abstract)? css_abstract_class : css_class, false);
			else
				this.write_navi_entry (cl, parent, (cl.is_abstract)? css_abstract_class : css_class, true);
		}
	}

	protected void write_navi_child_classes_without_childs (ClassHandler clh, Api.Node? parent) {
		Gee.Collection<Class> classes = clh.get_class_list ();
		this.write_navi_child_classes_without_childs_collection (classes, parent);
	}

	protected void write_navi_child_construction_methods (ConstructionMethodHandler cmh, Api.Node? parent) {
		Gee.Collection<Method> methods = cmh.get_construction_method_list ();
		this.write_navi_child_construction_methods_collection (methods, parent);
	}

	protected void write_navi_child_signals (Api.SignalHandler sh, Api.Node? parent) {
		Gee.Collection<Api.Signal> signals = sh.get_signal_list ();

		foreach (Api.Signal sig in signals) {
			if (sig == parent)
				this.write_navi_entry (sig, parent, css_signal, false);
			else
				this.write_navi_entry (sig, parent, css_signal, true);
		}
	}

	protected void write_navi_child_properties (PropertyHandler ph, Api.Node? parent) {
		Gee.Collection<Property> properties = ph.get_property_list ();

		foreach (Property p in properties) {
			string css;
			if (p.is_virtual)
				css = css_virtual_property;
			else if (p.is_abstract)
				css = css_abstract_property;
			else
				css = css_property;

			if (p == parent)
				this.write_navi_entry (p, parent, css, false);
			else
				this.write_navi_entry (p, parent, css, true);
		}
	}

	protected void write_navi_child_fields_collection (Gee.Collection<Field> fields, Api.Node? parent) {
		foreach (Field f in fields) {
			if (f == parent)
				this.write_navi_entry (f, parent, css_field, false);
			else
				this.write_navi_entry (f, parent, css_field, true);
		}
	}

	protected void write_navi_child_fields (FieldHandler fh, Api.Node? parent) {
		Gee.Collection<Field> fields = fh.get_field_list ();
		this.write_navi_child_fields_collection (fields, parent);
	}

	protected void write_navi_child_constants_collection (Gee.Collection<Constant> constants, Api.Node? parent) {
		foreach (Constant c in constants) {
			if (c == parent)
				this.write_navi_entry (c, parent, css_constant, false);
			else
				this.write_navi_entry (c, parent, css_constant, true);
		}
	}

	protected void write_navi_child_constants (ConstantHandler ch, Api.Node? parent) {
		Gee.Collection<Constant> constants = ch.get_constant_list ();
		this.write_navi_child_constants_collection (constants, parent);
	}

	protected void write_navi_child_structs_without_childs_collection (Gee.Collection<Struct> structs, Api.Node? parent) {
		foreach (Struct stru in structs) {
			if (stru == parent)
				this.write_navi_entry (stru, parent, css_struct, false);
			else
				this.write_navi_entry (stru, parent, css_struct, true);
		}
	}

	protected void write_navi_child_structs_without_childs (StructHandler strh, Api.Node? parent) {
		Gee.Collection<Struct> structs = strh.get_struct_list ();
		this.write_navi_child_structs_without_childs_collection (structs, parent);
	}

	protected void write_navi_child_delegates_collection (Gee.Collection<Delegate> delegates, Api.Node? parent) {
		foreach (Delegate del in delegates) {
			if (del == parent)
				this.write_navi_entry (del, parent, css_delegate, false);
			else
				this.write_navi_entry (del, parent, css_delegate, true);
		}
	}

	protected void write_navi_child_delegates (DelegateHandler delh, Api.Node? parent) {
		Gee.Collection<Delegate> delegates = delh.get_delegate_list ();
		this.write_navi_child_delegates_collection (delegates, parent);
	}

	protected void write_navi_child_interfaces_without_childs_collection (Gee.Collection<Interface> interfaces, Api.Node? parent) {
		foreach (Interface iface in interfaces) {
			if (iface == parent)
				this.write_navi_entry (iface, parent, css_interface, false);
			else
				this.write_navi_entry (iface, parent, css_interface, true);
		}
	}

	protected void write_navi_child_interfaces_without_childs (Namespace ifh, Api.Node? parent) {
		Gee.Collection<Interface> interfaces = ifh.get_interface_list ();
		this.write_navi_child_interfaces_without_childs_collection (interfaces, parent);
	}

	protected void write_navi_child_enums_without_childs_collection (Gee.Collection<Enum> enums, Api.Node? parent) {
		foreach (Enum en in enums) {
			if (en == parent)
				this.write_navi_entry (en, parent, css_enum, false);
			else
				this.write_navi_entry (en, parent, css_enum, true);
		}
	}

	protected void write_navi_child_enums_without_childs (EnumHandler eh, Api.Node? parent) {
		Gee.Collection<Enum> enums = eh.get_enum_list ();
		this.write_navi_child_enums_without_childs_collection (enums, parent);
	}

	protected void write_navi_child_error_domains_without_childs_collection (Gee.Collection<ErrorDomain> errordomains, Api.Node? parent) {
		foreach (ErrorDomain errdom in errordomains) {
			if (errdom == parent)
				this.write_navi_entry (errdom, parent, css_errordomain, false);
			else
				this.write_navi_entry (errdom, parent, css_errordomain, true);
		}
	}

	protected void write_navi_child_error_domains_without_childs (Namespace errdomh, Api.Node? parent) {
		Gee.Collection<ErrorDomain> errordomains = errdomh.get_error_domain_list ();
		this.write_navi_child_error_domains_without_childs_collection (errordomains, parent);
	}

	protected void write_navi_child_namespaces_without_childs (NamespaceHandler nsh, Api.Node? parent) {
		Gee.Collection<Namespace> namespaces = nsh.get_namespace_list ();
		foreach (Namespace ns in namespaces) {
			if (ns.name == null)
				continue ;

			if (ns == parent)
				this.write_navi_entry (ns, parent, css_namespace, false);
			else
				this.write_navi_entry (ns, parent, css_namespace, true);
		}
	}

	protected void write_package_note (Api.Node element) {
		string package = element.package.name;
		if (package == null)
			return ;

		writer.simple_tag ("br");
		writer.start_tag ("b").text ("Package:").end_tag ("b");
		writer.text (" ").text (package);
	}

	protected void write_namespace_note (Api.Node element) {
		Namespace? ns = element.nspace;
		if (ns == null)
			return ;

		if (ns.name == null)
			return ;

		writer.simple_tag ("br");
		writer.start_tag ("b").text ("Namespace:").end_tag ("b");
		writer.text (" ").text (ns.full_name());
	}

	private void write_brief_description (Api.Node element , Api.Node? pos) {
		Comment? doctree = element.documentation;
		if (doctree == null)
			return ;

		Gee.List<Block> description = doctree.content;
		if (description.size > 0) {
			writer.start_tag ("span", css_brief_description);
			writer.text (" - ");

			_renderer.set_container (pos);
			_renderer.render_children (description.get (0));

			writer.end_tag ("span");
		}
	}

	private void write_documentation (Api.Node element , Api.Node? pos) {
		Comment? doctree = element.documentation;
		if (doctree == null)
			return ;

		writer.start_tag ("div", css_description);

		_renderer.set_container (pos);
		_renderer.render (doctree);

		writer.end_tag ("div");
	}

	private void write_signature (Api.Node element , Api.Node? pos) {
		writer.start_tag ("div", css_code_definition);
		_renderer.set_container (pos);
		_renderer.render (element.signature);
		writer.end_tag ("div");
	}

	public void write_navi_packages_inline (Api.Tree tree) {
		writer.start_tag ("ul", css_navi);
		foreach (Package pkg in tree.get_package_list()) {
			if (pkg.is_visitor_accessible (settings)) {
				writer.start_tag ("li", get_html_css_class (pkg));
				writer.link (get_link (pkg, null), pkg.name);
				// brief description
				writer.end_tag ("li");
			}
			else {
				writer.start_tag ("li", get_html_css_class (pkg));
				writer.text (pkg.name);
				writer.end_tag ("li");
			}
		}
		writer.end_tag ("li");
	}

	public void write_navi_packages (Api.Tree tree) {
		writer.start_tag ("div", css_style_navigation);
		this.write_navi_packages_inline (tree);
		writer.end_tag ("div");
	}

	public void write_package_index_content (Api.Tree tree) {
		writer.start_tag ("div", css_style_content);
		writer.start_tag ("h1", css_title).text ("Packages:").end_tag ("h1");
		writer.simple_tag ("hr", css_headline_hr);

		WikiPage? wikiindex = (tree.wikitree == null)? null : tree.wikitree.search ("index.valadoc");
		if (wikiindex != null) {
			_renderer.set_container (null);
			_renderer.render (wikiindex.documentation);
		}

		writer.start_tag ("h2", css_title).text ("Content:").end_tag ("h2");
		writer.start_tag ("h3", css_title).text ("Packages:").end_tag ("h3");
		this.write_navi_packages_inline (tree);
		writer.end_tag ("div");
	}

	public void write_symbol_content (Api.Node node) {
		string full_name = node.full_name ();
		writer.start_tag ("div", css_style_content);
		writer.start_tag ("h1", css_title, full_name).text (node.name).end_tag ("h1");
		writer.simple_tag ("hr", css_headline_hr);
		this.write_image_block (node);
		writer.start_tag ("h2", css_title).text ("Description:").end_tag ("h2");
		this.write_signature (node, node);
		this.write_documentation (node, node);

		if (node.parent is Namespace) {
			writer.simple_tag ("br");
			this.write_namespace_note (node);
			this.write_package_note (node);
		}
		if (node.has_children ({
				Api.NodeType.ERROR_CODE,
				Api.NodeType.ENUM_VALUE,
				Api.NodeType.CREATION_METHOD,
				Api.NodeType.STATIC_METHOD,
				Api.NodeType.CLASS,
				Api.NodeType.STRUCT,
				Api.NodeType.ENUM,
				Api.NodeType.DELEGATE,
				Api.NodeType.METHOD,
				Api.NodeType.SIGNAL,
				Api.NodeType.PROPERTY,
				Api.NodeType.FIELD,
				Api.NodeType.CONSTANT
			})) {
			writer.start_tag ("h2", css_title).text ("Content:").end_tag ("h2");
			write_children_table (node, Api.NodeType.ERROR_CODE, "Error codes");
			write_children_table (node, Api.NodeType.ENUM_VALUE, "Enum values");
			write_children (node, Api.NodeType.CREATION_METHOD, "Creation methods", node);
			write_children (node, Api.NodeType.STATIC_METHOD, "Static methods", node);
			write_children (node, Api.NodeType.CLASS, "Classes", node);
			write_children (node, Api.NodeType.STRUCT, "Structs", node);
			write_children (node, Api.NodeType.ENUM, "Enums", node);
			write_children (node, Api.NodeType.CONSTANT, "Constants", node);
			write_children (node, Api.NodeType.PROPERTY, "Properties", node);
			write_children (node, Api.NodeType.DELEGATE, "Delegates", node);
			write_children (node, Api.NodeType.METHOD, "Methods", node);
			write_children (node, Api.NodeType.SIGNAL, "Signals", node);
			write_children (node, Api.NodeType.FIELD, "Fields", node);
		}
		writer.end_tag ("div");
	}

	protected void write_child_namespaces (NamespaceHandler nh, Api.Node? parent) {
		Gee.ArrayList<Namespace> nsl = new Gee.ArrayList<Namespace> ();
		this.fetch_subnamespace_names (nh, nsl);

		if (nsl.size == 0)
			return ;

		if (nsl.size == 1) {
			if (nsl.get(0).name == null)
				return ;
		}

		bool with_childs = (parent == null)? false : parent is Package;

		writer.start_tag ("h3", css_title).text ("Namespaces:").end_tag ("h3");
		writer.start_tag ("ul", css_inline_navigation);
		foreach (Namespace child in nsl) {
			if (child.name != null) {
				writer.start_tag ("li", css_namespace);
				writer.link (get_link (child, parent), child.name);
				this.write_brief_description (child, parent);
				writer.end_tag ("li");
				if (with_childs == true) {
					write_children (child, Api.NodeType.INTERFACE, "Interfaces", parent);
					write_children (child, Api.NodeType.CLASS, "Classes", parent);
					write_children (child, Api.NodeType.STRUCT, "Structs", parent);
					write_children (child, Api.NodeType.ENUM, "Enums", parent);
					write_children (child, Api.NodeType.ERROR_DOMAIN, "Error domains", parent);
					write_children (child, Api.NodeType.DELEGATE, "Delegates", parent);
					write_children (child, Api.NodeType.METHOD, "Methods", parent);
					write_children (child, Api.NodeType.FIELD, "Fields", parent);
					write_children (child, Api.NodeType.CONSTANT, "Constants", parent);
				}
			}
		}
		writer.end_tag ("ul");
	}

	protected void write_child_dependencies (Package package, Api.Node? parent) {
		Gee.Collection<Package> deps = package.get_full_dependency_list ();
		if (deps.size == 0)
			return ;

		writer.start_tag ("h2", css_title).text ("Dependencies:").end_tag ("h2");
		writer.start_tag ("ul", css_inline_navigation);
		foreach (Package p in deps) {
			string link = this.get_link(p, parent);
			if (link == null)
				writer.start_tag ("li", css_package, p.name).text (p.name).end_tag ("li");
			else {
				writer.start_tag ("li", css_package);
				writer.link (get_link (p, parent), p.name);
				writer.end_tag ("li");
			}
		}
		writer.end_tag ("ul");
	}

	protected string get_img_path (Api.Node element) {
		return "img/" + element.full_name () + ".png";
	}

	protected string get_img_real_path (Api.Node element) {
		return this.settings.path + "/" + element.package.name + "/" + "img/" + element.full_name () + ".png";
	}

	protected void write_children (Api.Node node, Api.NodeType type, string type_string, Api.Node? container) {
		var children = node.get_children_by_type (type);
		if (children.size > 0) {
			writer.start_tag ("h3", css_title).text (type_string).text (":").end_tag ("h3");
			writer.start_tag ("ul", css_inline_navigation);
			foreach (Api.Node child in children) {
				writer.start_tag ("li", get_html_css_class (child));
				writer.link (get_link (child, container), child.name);
				this.write_brief_description (child, container);
				writer.end_tag ("li");
			}
			writer.end_tag ("ul");
		}
	}

	private void write_children_table (Api.Node node, Api.NodeType type, string type_string) {
		Gee.Collection<Api.Node> children = node.get_children_by_type (Api.NodeType.ENUM_VALUE);
		if (children.size > 0) {
			writer.start_tag ("h3", css_title).text (type_string).text (":").end_tag ("h3");
			writer.start_tag ("table", get_html_css_class (node));
			foreach (Api.Node child in children) {
				writer.start_tag ("tr");

				writer.start_tag ("td", get_html_css_class (child), child.name);
				writer.text (child.name);
				writer.end_tag ("td");

				writer.start_tag ("td");
				this.write_documentation (child, node);
				writer.end_tag ("td");

				writer.end_tag ("tr");
			}
			writer.end_tag ("table");
		}
	}

	protected void write_image_block (Api.Node element) {
		if (!(element is Class || element is Interface || element is Struct)) {
			return;
		}

		string realimgpath = this.get_img_real_path (element);
		string imgpath = this.get_img_path (element);

		if (element is Class) {
			Diagrams.write_class_diagram ((Class)element, realimgpath);
		}
		else if (element is Interface) {
			Diagrams.write_interface_diagram ((Interface)element, realimgpath);
		}
		else if (element is Struct) {
			Diagrams.write_struct_diagram ((Struct)element, realimgpath);
		}

		writer.start_tag ("h2", css_title).text ("Object Hierarchy:").end_tag ("h2");
		writer.image (imgpath, "Object hierarchy for %s".printf (element.name), css_diagram);
	}

	public void write_namespace_content (Namespace node, Api.Node? parent) {
		writer.start_tag ("div", css_style_content);
		writer.start_tag ("h1", css_title).text (node.name == null ? "Global Namespace" : node.full_name ()).end_tag ("h1");
		writer.simple_tag ("hr", css_hr);
		writer.start_tag ("h2", css_title).text ("Description:").end_tag ("h2");

		this.write_documentation (node, parent);

		writer.start_tag ("h2", css_title).text ("Content:").end_tag ("h2");

		if (node.name == null)
			this.write_child_namespaces ((Package) node.parent, parent);
		else
			this.write_child_namespaces (node, parent);

		write_children (node, Api.NodeType.INTERFACE, "Interfaces", parent);
		write_children (node, Api.NodeType.CLASS, "Classes", parent);
		write_children (node, Api.NodeType.STRUCT, "Structs", parent);
		write_children (node, Api.NodeType.ENUM, "Enums", parent);
		write_children (node, Api.NodeType.ERROR_DOMAIN, "Error domains", parent);
		write_children (node, Api.NodeType.DELEGATE, "Delegates", parent);
		write_children (node, Api.NodeType.METHOD, "Methods", parent);
		write_children (node, Api.NodeType.FIELD, "Fields", parent);
		write_children (node, Api.NodeType.CONSTANT, "Constants", parent);
		writer.end_tag ("div");
	}

	protected void write_package_content (Package node, Api.Node? parent, WikiPage? wikipage = null) {
		writer.start_tag ("div", css_style_content);
		writer.start_tag ("h1", css_title, node.name).text (node.name).end_tag ("h1");
		writer.simple_tag ("hr", css_headline_hr);
		writer.start_tag ("h2", css_title).text ("Description:").end_tag ("h2");

		if (wikipage != null) {
			_renderer.set_container (parent);
			_renderer.render (wikipage.documentation);
		}

		writer.start_tag ("h2", css_title).text ("Content:").end_tag ("h2");

		this.write_child_namespaces (node, parent);

		foreach (Api.Node child in node.get_children_by_type (Api.NodeType.NAMESPACE)) {
			if (child.name == null) {
				write_children (child, Api.NodeType.INTERFACE, "Interfaces", parent);
				write_children (child, Api.NodeType.CLASS, "Classes", parent);
				write_children (child, Api.NodeType.STRUCT, "Structs", parent);
				write_children (child, Api.NodeType.ENUM, "Enums", parent);
				write_children (child, Api.NodeType.ERROR_DOMAIN, "Error domains", parent);
				write_children (child, Api.NodeType.DELEGATE, "Delegates", parent);
				write_children (child, Api.NodeType.METHOD, "Methods", parent);
				write_children (child, Api.NodeType.FIELD, "Fields", parent);
				write_children (child, Api.NodeType.CONSTANT, "Constants", parent);
			}
		}

		this.write_child_dependencies (node, parent);
		writer.end_tag ("div");
	}

	protected void write_file_header (string css, string? title) {
		writer.start_tag ("html");
		writer.start_tag ("head");
		writer.start_tag ("title").text ("Vala Binding Reference").end_tag ("title");
		writer.stylesheet_link (css);
		writer.end_tag ("head");
		writer.start_tag ("body");
		writer.start_tag ("div", css_site_header);
		writer.text ("%s Reference Manual".printf (title == null ? "" : title));
		writer.end_tag ("div");
		writer.start_tag ("div", css_style_body);
	}

	protected void write_file_footer () {
		writer.end_tag ("div");
		writer.simple_tag ("br");
		writer.start_tag ("div", "site_foother");
		writer.text ("Generated by ");
		writer.link ("http://www.valadoc.org/", "Valadoc");
		writer.end_tag ("div");
		writer.end_tag ("body");
		writer.end_tag ("html");
	}
}

